require 'find'
require 'open3'

module RedmineInstaller
  class Redmine < TaskModule

    attr_reader :database
    attr_accessor :root

    REQUIRED_FILES = [
      'app',
      'lib',
      'config',
      'public',
      'db',
      'Gemfile',
      'Rakefile',
      'config.ru',
      File.join('lib', 'redmine'),
      File.join('lib', 'redmine.rb'),
    ]

    # BACKUP_EXCLUDE_FILES = ['log', 'tmp']

    CHECK_N_INACCESSIBLE_FILES = 10

    def initialize(task, root=nil)
      super(task)
      @root = root.to_s
    end

    def database_yml_path
      File.join(root, 'config', 'database.yml')
    end

    def configuration_yml_path
      File.join(root, 'config', 'configuration.yml')
    end

    def files_path
      File.join(root, 'files')
    end

    def plugins_path
      File.join(root, 'plugins')
    end

    # Ask for REDMINE_ROOT (if wasnt set) and check access rights
    #
    def ensure_valid_root
      if root.empty?
        puts
        @root = prompt.ask('Path to redmine root:', required: true, default: '.')
      end

      @root = File.expand_path(@root)

      unless Dir.exist?(@root)
        create_dir(@root)
      end

      logger.info("REDMINE_ROOT: #{@root}")

      inaccessible_files = []

      Find.find(@root).each do |item|
        if !File.writable?(item) || !File.readable?(item)
          inaccessible_files << item
        end

        if inaccessible_files.size > CHECK_N_INACCESSIBLE_FILES
          break
        end
      end

      if inaccessible_files.any?
        error "Redmine root contains inaccessible files. Make sure that all files in #{@root} are readable/writeable for user #{env_user}.", "(limit #{CHECK_N_INACCESSIBLE_FILES} files: #{inaccessible_files.join(', ')})"
      end
    end

    # Create and configure rails database
    #
    def create_database_yml
      print_title('Creating database configuration')

      @database = Database.create(self)
      logger.info("Database initialized #{@database}")
    end

    # Create and configure configuration
    # For now only email
    #
    def create_configuration_yml
      print_title('Creating email configuration')

      @configuration = Configuration.create(self)
      logger.info("Configuration initialized #{@configuration}")
    end

    # Run install commands (command might ask for additional informations)
    #
    def install
      print_title('Redmine installing')

      Dir.chdir(root) do
        # Gems can be locked on bad version
        FileUtils.rm_f('Gemfile.lock')

        # Install new gems
        bundle_install

        # Ensuring database
        rake_db_create

        # Migrating
        rake_db_migrate

        # Plugin migrating
        rake_redmine_plugin_migrate

        # Generate secret token
        rake_generate_secret_token

        # Install easyproject
        rake_easyproject_install if easyproject?
      end
    end

    def upgrade
      print_title('Redmine upgrading')

      Dir.chdir(root) do
        # Gems can be locked on bad version
        FileUtils.rm_f('Gemfile.lock')

        # Install new gems
        bundle_install

        # Migrating
        rake_db_migrate

        # Plugin migrating
        rake_redmine_plugin_migrate

        # Generate secret token
        rake_generate_secret_token

        # Install easyproject
        rake_easyproject_install if easyproject?
      end
    end

    def delete_root
      Dir.chdir(root) do
        Dir.entries('.').each do |entry|
          next if entry == '.' || entry == '..'
          FileUtils.remove_entry_secure(entry)
        end
      end

      logger.info("#{root} content was deleted")
    end

    def copy_root(other_redmine)
      Dir.chdir(other_redmine.root) do
        Dir.entries('.').each do |entry|
          next if entry == '.' || entry == '..'
          FileUtils.mv(entry, root)
        end
      end

      logger.info("Copyied from #{other_redmine.root} into #{root}")
    end

    # Copy instance files which cannot be deleted
    #
    def copy_instance_files_from(other_redmine)
      Dir.chdir(root) do
        # Copy database.yml
        FileUtils.cp(other_redmine.database_yml_path, database_yml_path)

        # Copy configuration.yml
        if File.exist?(other_redmine.configuration_yml_path)
          FileUtils.cp(other_redmine.configuration_yml_path, configuration_yml_path)
        end

        # Copy files
        FileUtils.cp_r(other_redmine.files_path, root)
      end

      logger.info('Important files was copyied')
    end

    # New package may not have all plugins
    #
    def copy_missing_plugins_from(other_redmine)
      Dir.chdir(other_redmine.plugins_path) do
        Dir.entries('.').each do |plugin|
          next if plugin == '.' || plugin == '..'

          # Plugin is not directory
          unless File.directory?(plugin)
            next
          end

          to = File.join(plugins_path, plugin)

          unless Dir.exist?(to)
            FileUtils.cp_r(plugin, to)
          end
        end
      end
    end

    def validate
      # Check for required files
      Dir.chdir(root) do
        REQUIRED_FILES.each do |path|
          unless File.exist?(path)
            error "Redmine #{root} is not valid. Missing #{path}."
          end
        end
      end

      # Plugins are in right dir
      Dir.glob(File.join(root, 'vendor', 'plugins', '*')).each do |path|
        if File.directory?(path)
          error "Plugin should be on plugins dir. On vendor/plugins is #{path}"
        end
      end
    end

    # Backup:
    # - complete redmine (except log, tmp)
    # - production database
    def make_backup
      print_title('Data backup')

      selected = prompt.select('What type of backup do you want?',
        'Complete (entire redmine, files and database)' => :complete,
        'Standart (configurations, files and database)' => :standart,
        'Only database' => :database,
        'Nothing' => :nothing)

      logger.info("Backup type: #{selected}")

      # Dangerous option
      if selected == :nothing
        if prompt.yes?('Are you sure?', default: true)
          logger.info('Backup option nothing was confirmed')
          return
        else
          return make_backup
        end
      end

      backup_root = prompt.ask('Path to backup root:', required: true)
      backup_root = File.expand_path(backup_root)

      @backup_dir = File.join(backup_root, Time.now.strftime('backup_%d%m%Y_%H%M%S'))
      create_dir(@backup_dir)

      files_to_backup = []
      Dir.chdir(root) do
        case selected
        when :complete
          files_to_backup = Dir.glob(File.join('**', '{*,.*}'))
        when :standart
          files_to_backup = Dir.glob(File.join('files', '**', '{*,.*}'))
          files_to_backup << File.join('config', 'database.yml')
          files_to_backup << File.join('config', 'configuration.yml')
        end
      end

      if files_to_backup.any?
        @backup_package = File.join(@backup_dir, 'redmine.zip')

        Dir.chdir(root) do
          puts
          puts 'Files backup'
          Zip::File.open(@backup_package, Zip::File::CREATE) do |zipfile|
            progressbar = TTY::ProgressBar.new(PROGRESSBAR_FORMAT, total: files_to_backup.size, frequency: 2)

            files_to_backup.each do |entry|
              zipfile.add(entry, entry)
              progressbar.advance(1)
            end

            progressbar.finish
          end
        end

        logger.info('Files backed up')
      end

      @database = Database.init(self)
      @database.make_backup(@backup_dir)

      logger.info('Database backed up')
    end

    def clean_up
    end

    private

      def run_command(title, cmd)
        puts '-->'
        puts "--> #{pastel.yellow(title)}"
        puts '-->'

        logger.std("--> #{title} (#{cmd})")

        status = Open3.popen2e(cmd) do |input, output, wait_thr|
          input.close

          output.each_line do |line|
            logger.std(line)
            puts line
          end

          wait_thr.value
        end

        status.success?
      rescue
        false
      end

      def bundle_install
        status = run_command('Bundle install', "bundle install #{task.options.bundle_options}")

        # Even if bundle could not install all gem EXIT_SUCCESS is returned
        if !status || !File.exist?('Gemfile.lock')
          puts
          selected = prompt.select("Gemfile.lock wasn't created. Please choose one option:",
            'Try again' => :try_again,
            'Change bundle options' => :change_options,
            'Cancel' => :cancel)

          case selected
          when :try_again
            bundle_install
          when :change_options
            task.options.bundle_options = prompt.ask('New options:', default: task.options.bundle_options)
            bundle_install
          when :cancel
            error('Operation canceled by user')
          end
        end
      end

      def rake_db_create
        # Always return 0
        run_command('Database preparation', 'RAILS_ENV=production bundle exec rake db:create')
      end

      def rake_db_migrate
        status = run_command('Database migration', 'RAILS_ENV=production bundle exec rake db:migrate')

        unless status
          puts
          selected = prompt.select('Migration end with error. Please choose one option:',
            'Try again' => :try_again,
            'Change database configuration' => :change_configuration,
            'Cancel' => :cancel)

          case selected
          when :try_again
            rake_db_migrate
          when :change_configuration
            create_database_yml
            rake_db_migrate
          when :cancel
            error('Operation canceled by user')
          end
        end
      end

      def rake_redmine_plugin_migrate
        status = run_command('Plugins migration', 'RAILS_ENV=production bundle exec rake redmine:plugins:migrate')

        unless status
          puts
          selected = prompt.select('Plugin migration end with error. Please choose one option:',
            'Try again' => :try_again,
            'Continue' => :continue,
            'Cancel' => :cancel)

          case selected
          when :try_again
            rake_redmine_plugin_migrate
          when :continue
            logger.warn('Plugin migration end with error but step was skipped.')
          when :cancel
            error('Operation canceled by user')
          end
        end
      end

      def rake_generate_secret_token
        status = run_command('Generate secret token', 'RAILS_ENV=production bundle exec rake generate_secret_token')

        unless status
          puts
          selected = prompt.select('Secret token could not be created. Please choose one option:',
            'Try again' => :try_again,
            'Continue' => :continue,
            'Cancel' => :cancel)

          case selected
          when :try_again
            rake_generate_secret_token
          when :continue
            logger.warn('Secret token could not be created but step was skipped.')
          when :cancel
            error('Operation canceled by user')
          end
        end
      end

      def rake_easyproject_install
        status = run_command('Install easyproject', 'RAILS_ENV=production bundle exec rake easyproject:install')

        unless status
          puts
          selected = prompt.select('Easyproject could not be installed. Please choose one option:',
            'Try again' => :try_again,
            'Cancel' => :cancel)

          case selected
          when :try_again
            rake_easyproject_install
          when :cancel
            error('Operation canceled by user')
          end
        end
      end

      def easyproject?
        Dir.entries(plugins_path).include?('easyproject')
      end

  end
end
