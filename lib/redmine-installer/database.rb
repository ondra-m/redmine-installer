module RedmineInstaller
  class Database
    extend Utils

    def self.create_config(redmine)
      # Maybe: enum_select
      klass = prompt.select('What database do you want use?') do |menu|
        menu.choice 'MySQL', MySQL
        menu.choice 'PostgreSQL', PostgreSQL
      end

      # Get parameters and create configuration
      database = klass.new(redmine)
      database.get_parameters
      database.make_config
      database
    end

    def self.init(redmine)
      unless File.exist?(redmine.database_yml_path)
        error "Database configuration files does not exist on #{redmine.root}."
      end

      definitions = YAML.load_file(redmine.database_yml_path)
      definition = definitions['production']

      unless definition.is_a?(Hash)
        error 'Unknow database definition'
      end

      case definition['adapter']
      when 'mysql', 'mysql2'
        klass = MySQL
      when 'pg', 'postgresql'
        klass = PostgreSQL
      else
        error "Unknow database adapter #{definition['adapter']}."
      end

      database = klass.new(redmine)
      database.set_paramaters(definition)
      database
    end

    class Base
      include RedmineInstaller::Utils

      attr_reader :backup

      def initialize(redmine)
        @redmine = redmine
      end

      def backuped?
        @backup && File.exist?(@backup)
      end

      def get_parameters
        @database = prompt.ask('Database:', required: true)
        @host = prompt.ask('Host:', default: 'localhost', required: true)
        @username = prompt.ask('Username:', required: true)
        @password = prompt.mask('Password:', required: true)
        @encoding = prompt.ask('Encoding:', default: 'utf8', required: true)
        @port = prompt.ask('Port:', default: default_port, convert: :int, required: true)

        # @database = 'test'
        # @host = 'localhost'
        # @username = 'postgres'
        # @password = 'postgres'
        # @encoding = 'utf8'
        # @port = default_port
      end

      def set_paramaters(definition)
        @database = definition['database']
        @username = definition['username']
        @password = definition['password']
        @encoding = definition['encoding']
        @host = definition['host']
        @port = definition['port']
      end

      def make_config
        File.open(@redmine.database_yml_path, 'w') do |f|
          f.puts(YAML.dump(build))
        end
      end

      def make_backup(dir)
        puts 'Database backuping'
        @backup = File.join(dir, "#{@database}.sql")
        Kernel.system backup_command(@backup)
      end

    #   def restore_from_backup
    #     return unless backuped?

    #     ok('Database restoring'){
    #       Kernel.system drop_tables_command
    #       Kernel.system restore_command(@backup)
    #     }
    #   end

      def build
        data = {}
        data['adapter'] = adapter_name
        data['username'] = @username
        data['database'] = @database
        data['password'] = @password
        data['encoding'] = @encoding
        data['host'] = @host
        data['port'] = @port

        {
          'production' => data,
          'development' => data
        }
      end

      def to_s
        "<#{class_name} #{@username}@#{@host}:#{@port} (#{@encoding})>"
      end

    end

    class MySQL < Base

      def default_port
        3306
      end

      def adapter_name
        'mysql2'
      end

      def command_args
        args = []
        args << "--host=#{@host}"         unless @host.to_s.empty?
        args << "--port=#{@port}"         unless @port.to_s.empty?
        args << "--user=#{@username}"     unless @username.to_s.empty?
        args << "--password=#{@password}" unless @password.to_s.empty?
        args.join(' ')
      end

      def backup_command(file)
        "mysqldump --add-drop-database --compact --result-file=#{file} #{command_args} #{@database}"
      end

      # def restore_command(file)
      #   "mysql #{command_args} #{@database} < #{file}"
      # end

      # def drop_tables_command
      #   execute = "SELECT CONCAT('DROP TABLE IF EXISTS ', table_name, ';') " +
      #             "FROM information_schema.tables " +
      #             "WHERE table_schema = '#{@database}';"

      #   drops = `mysql #{command_args} #{@database} --execute=\"#{execute}\" --silent`
      #   drops = drops.gsub("\n", '')

      #   "mysql #{command_args} #{@database} --execute=\"#{drops}\""
      # end

    end

    class PostgreSQL < Base

      def default_port
        5432
      end

      def adapter_name
        'postgresql'
      end

      def command_args
        args = []
        args << "--host=#{@host}"         unless @host.to_s.empty?
        args << "--port=#{@port}"         unless @port.to_s.empty?
        args << "--username=#{@username}" unless @username.to_s.empty?
        args.join(' ')
      end

      def backup_command(file)
        if @password.empty?
          pass = ''
        else
          pass = "PGPASSWORD=\"#{@password}\""
        end

        "#{pass} pg_dump --clean #{command_args} #{@database} --file=#{file}"
      end

    end

  end
end
