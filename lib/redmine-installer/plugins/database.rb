module Redmine::Installer::Plugin
  class Database < Base
    
    DATABASE_YML_PATH = 'config/database.yml'

    attr_reader :params

    def initialize
      @params = Redmine::Installer::ConfigParams.new
      @params.add('database')
      @params.add('host').default('localhost')
      @params.add('username')
      @params.add('password')
      @params.add('encoding').default('utf8')
    end

    # Transform ConfigParams into rails database.yml structure.
    # Method creates production and developemtn environemnt
    # with the same parameters.
    def build
      data = Hash[@params.map{|p| [p.name, p.value]}]
      data['adapter'] = self.adapter_name
      data = {
        'production' => data,
        'development' => data,
      }

      return DATABASE_YML_PATH, YAML.dump(data)
    end

    class MySQL < Database
      def adapter_name
        'mysql2'
      end
    end

    class PostgreSQL < Database
      def adapter_name
        'pg'
      end
    end

  end
end
