module RedmineInstaller
  class Upgrade < Task

    def up
      @environment.check
      @target_redmine.ensure_and_valid_root
      @target_redmine.validate
      @target_redmine.check_running_state

      @package.ensure_and_valid_package
      @package.extract

      @temp_redmine.root = @package.redmine_root

      @target_redmine.make_backup

      @temp_redmine.copy_importants_from(@target_redmine)
      @temp_redmine.copy_missing_plugins_from(@target_redmine)

      begin
        @temp_redmine.upgrade
      rescue => e
        if @target_redmine.database && @target_redmine.database.backuped?
          addition_message = "Database have been backed up on #{pastel.bold(@target_redmine.database.backup)}."
        else
          addition_message = ''
        end

        error("Upgrade failed due to #{e.message}. #{addition_message}")
      end

      print_title('Finishing installation')
      ok('Cleaning root'){ @target_redmine.delete_root }
      ok('Moving redmine to target directory'){ @target_redmine.move_from(@temp_redmine) }
      ok('Cleanning up'){ @package.clean_up }
      ok('Moving installer log'){ logger.move_to(@target_redmine) }

      puts
      puts pastel.bold('Redmine was upgraded')
      logger.info('Redmine was upgraded')
    end

    def down
      # @temp_redmine.clean_up
      # @package.clean_up

      puts
      puts "(Log is located on #{pastel.bold(logger.path)})"
    end

  end
end
