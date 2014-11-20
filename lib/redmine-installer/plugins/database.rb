require 'yaml'

module Redmine::Installer::Plugin
  class Database < Base

    DATABASE_YML_PATH = 'config/database.yml'
    DATABASE_BACKUP_DIR = '__database'

    attr_reader :params

    def self.load_all(redmine_root)
      database_file = File.join(redmine_root, DATABASE_YML_PATH)
      return [] unless File.exist?(database_file)

      to_return = []
      definitions = YAML.load_file(database_file)
      definitions.each do |name, data|

        klass = all.detect{|klass| klass.adapter_name == data['adapter']}

        next if klass.nil?

        klass = klass.new
        klass.load(data)

        to_return << klass
      end
      to_return
    end

    def self.backup_all(redmine_root, backup_dir)
      load_all(redmine_root).each do |klass|
        klass.backup(backup_dir)
      end
    end

    def self.restore_all(redmine_root, backup_dir)
      load_all(redmine_root).each do |klass|
        klass.restore(backup_dir)
      end
    end

    def initialize
      @params = Redmine::Installer::ConfigParams.new
      @params.add('database')
      @params.add('host').default('localhost')
      @params.add('username')
      @params.add('password').hide(true)
      @params.add('encoding').default('utf8')
    end

    # Transform ConfigParams into rails database.yml structure.
    # Method creates production and developemtn environemnt
    # with the same parameters.
    def build
      data = Hash[@params.map{|p| [p.name, p.value]}]
      data['adapter'] = self.class.adapter_name
      data = {
        'production' => data,
        'development' => data,
      }
      data
    end

    # Load paramaters for connection
    def load(data)
      data.each do |name, value|
        # Get param
        param = @params[name]

        # Unsupported key or unnecessary parameter
        next if param.nil?

        # Save value
        param.value = value
      end
    end

    def make_config(redmine_root)
      File.open(File.join(redmine_root, DATABASE_YML_PATH), 'w') do |f|
        f.puts(YAML.dump(build))
      end
    end

    def file_for_backup(dir)
      FileUtils.mkdir_p(File.join(dir, DATABASE_BACKUP_DIR))
      File.join(dir, DATABASE_BACKUP_DIR, "#{self.class.adapter_name}.#{params['database'].value}.dump")
    end

    def backup(dir)
      file = file_for_backup(dir)

      # More enviroments can use the same database
      return if File.exist?(file)

      Kernel.system(command_for_backup(file))
    end

    def restore(dir)
      file = file_for_backup(dir)

      # More enviroments can use the same database
      return unless File.exist?(file)

      Kernel.system(command_for_restore(file))
    end

    # Get valu from param
    def get(name)
      params[name].value
    end


    # =========================================================================
    # MySQL

    class MySQL < Database
      def self.adapter_name
        'mysql2'
      end

      def initialize
        super
        @params.add('port').default(3306)
      end

      def command_args
        "-h #{params['host'].value} -P #{get('port')} -u #{get('username')} -p#{get('password')} #{get('database')}"
      end

      def command_for_backup(file)
        "mysqldump --add-drop-database #{command_args} > #{file}"
      end

      def command_for_restore(file)
        "mysql #{command_args} < #{file}"
      end
    end


    # =========================================================================
    # PostgreSQL

    class PostgreSQL < Database
      def self.adapter_name
        'pg'
      end

      def initialize
        super
        @params.add('port').default(5432)
      end

      def command(comm, file)
        %{PGPASSWORD="#{get('password')}" #{comm} -i -h #{get('host')} -p #{get('port')} -U #{get('username')} -Fc -f #{file}}
      end

      def command_for_backup(file)
        command('pg_dump', file)
      end

      def command_for_restore(file)
        command('psql', file)
      end
    end

  end
end
