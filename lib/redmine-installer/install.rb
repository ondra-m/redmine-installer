module RedmineInstaller
  class Install < Task

    def initialize(package, redmine_root, **options)
      super(**options)

      @environment = Environment.new(self)
      @package = Package.new(self, package)
      @target_redmine = Redmine.new(self, redmine_root)
      @temp_redmine = Redmine.new(self)
    end

    def up
      @temp_redmine.valid_options
      @environment.check
      @target_redmine.ensure_and_valid_root
      @package.ensure_and_valid_package
      @package.extract

      @temp_redmine.root = @package.redmine_root

      @temp_redmine.create_database_yml
      @temp_redmine.create_configuration_yml
      @temp_redmine.install

      print_title('Finishing installation')
      ok('Cleaning root'){ @target_redmine.delete_root }
      ok('Moving redmine to target directory'){ @target_redmine.move_from(@temp_redmine) }
      ok('Cleanning up'){ @package.clean_up }
      ok('Moving installer log'){ logger.move_to(@target_redmine, suffix: 'install') }

      puts
      puts pastel.bold('Redmine was installed')
      logger.info('Redmine was installed')
    end

    def down
      @temp_redmine.clean_up
      @package.clean_up

      puts
      puts "(Log is located on #{pastel.bold(logger.path)})"
    end

  end
end
