module RedmineInstaller
  class Backup
    extend Utils

    def self.backup(redmine_root)
      @target_redmine = Redmine.new(self, redmine_root)
      @target_redmine.ensure_and_valid_root
      @target_redmine.validate
      @target_redmine.check_running_state
      @target_redmine.make_backup

      puts
      puts pastel.bold('Redmine was backuped')
      logger.info('Redmine was backuped')
    end

  end
end
