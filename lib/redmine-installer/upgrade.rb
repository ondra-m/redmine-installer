module RedmineInstaller
  class Upgrade < Task

    def up
      @environment.check
      @target_redmine.ensure_valid_root
      @target_redmine.validate
      @package.ensure_valid_package
      @package.extract

      @temp_redmine.root = @package.redmine_root

      @target_redmine.make_backup

      @temp_redmine.copy_instance_files_from(@target_redmine)
      @temp_redmine.copy_missing_plugins_from(@target_redmine)

      begin
        @temp_redmine.upgrade
      rescue => e
        if @target_redmine.database && @target_redmine.database.backuped?
          if prompt.yes?("Upgrade failed. Do you want restore database backup?", default: true)
            @target_redmine.database.restore_from_backup
            puts 'Database restored'
            logger.info('Database restored')
          else
            logger.warn('Upgrade failed but restore was rejected')
          end
        end

        error('Upgrade failed')
      end

      @target_redmine.delete_root
      @target_redmine.copy_root(@temp_redmine)

      @package.clean_up

      puts pastel.bold('Redmine was upgraded')
      logger.info('Redmine was upgraded')
    end

  end
end
