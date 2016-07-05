module RedmineInstaller
  class Install < Task

    def up
      @environment.check
      @target_redmine.ensure_and_valid_root
      @package.ensure_and_valid_package
      @package.extract

      @temp_redmine.root = @package.redmine_root

      @temp_redmine.create_database_yml
      @temp_redmine.create_configuration_yml
      @temp_redmine.install

      @target_redmine.delete_root

      @target_redmine.move_from(@temp_redmine)
      @package.clean_up

      puts
      puts pastel.bold('Redmine was installed')
      logger.info('Redmine was installed')
    end

    def down
      @temp_redmine.clean_up
      @package.clean_up
    end

  end
end
