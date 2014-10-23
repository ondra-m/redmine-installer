require 'fileutils'

module Redmine::Installer::Step
  class BackUp < Base

    DEFAULT_BACKUP_DIR = File.join(Dir.home, 'redmine-backups')

    def up
      choices = {}
      choices[:full_backup] = t(:full_backup)
      choices[:backup] = t(:backup)
      choices[:skip] = t(:skip)

      answer = choose(:do_you_want_backup_redmine, choices, default: :backup)

      case answer
      when :full_backup
        do_full_backup
      when :backup
        do_backup
      end

      binding.pry unless @__binding
    end

    private

      def check_backup_dir
        if base.backup_dir.nil?
          dir = ask(:what_dir_for_backups, default: DEFAULT_BACKUP_DIR)
          dir = File.expand_path(dir)

          try_create_dir(dir) unless Dir.exist?(dir)

          base.backup_dir = dir
        end
      end

      def create_current_backup_dir
        @current_backup_dir = File.join(base.backup_dir, Time.now.strftime('backup_%d%m%Y_%H%M%S'))
        try_create_dir(@current_backup_dir)
      end

      def do_full_backup
        check_backup_dir
        create_current_backup_dir
      end

      def do_backup
        check_backup_dir
        create_current_backup_dir

        # create config dir
        config_dir = File.join(@current_backup_dir, 'config')
        FileUtils.mkdir(config_dir)

        # database.yml
        database_file = File.join(base.redmine_root, plugin::Database::DATABASE_YML_PATH)
        FileUtils.cp(database_file, config_dir) if File.exist?(database_file)

        # configuration.yml
        configuration_file = File.join(base.redmine_root, plugin::EmailSending::CONFIGURATION_YML_PATH)
        FileUtils.cp(configuration_file, config_dir) if File.exist?(configuration_file)

        # files
        FileUtils.cp_r(File.join(base.redmine_root, 'files'), @current_backup_dir)

        # database dump
        plugin::Database.backup_all(base.redmine_root, @current_backup_dir)
      end

  end
end
