module RedmineInstaller
  class RestoreDB < Task

    def initialize(database_dump, redmine_root)
      super(database_dump: database_dump.to_s)

      @environment = Environment.new(self)
      @redmine = Redmine.new(self, redmine_root)
    end

    def up
      @environment.check

      @redmine.valid_options
      @redmine.ensure_and_valid_root
      @redmine.validate
      @redmine.check_running_state
      @redmine.restore_db

      puts
      puts pastel.bold('Database was restored')
      logger.info('Database was restored')
    end

  end
end
