require 'fileutils'
require 'zip'

module Redmine::Installer::Step
  class Backup < Base

    DEFAULT_BACKUP_DIR = File.join(Dir.home, 'redmine-backups')

    def up
      choices = {}
      choices[:full_backup] = t(:full_backup)
      choices[:backup] = t(:backup)
      choices[:only_database] = t(:only_database)
      choices[:skip] = t(:skip)

      @backup_type ||= choose(:do_you_want_backup_redmine, choices, default: :backup)

      case @backup_type
      when :full_backup
        do_full_backup
      when :backup
        do_backup
      when :only_database
        database_backup
      end
    end

    def down
      if @database_backed_up
        say(:restoring_database)
        database_restore
      end
    end

    def final
      if @current_backup_dir
        say t(:backup_is_stored_at, dir: @current_backup_dir), 2
      end
    end

    def save(configuration)
      configuration['backup_type'] = @backup_type
      configuration['backup_dir'] = @backup_dir
    end

    def load(configuration)
      @backup_type = configuration['backup_type']
      @backup_dir = configuration['backup_dir']
    end

    private

      def check_backup_dir
        if @backup_dir.nil?
          dir = ask(:what_dir_for_backups, default: DEFAULT_BACKUP_DIR)
          dir = File.expand_path(dir)

          try_create_dir(dir) unless Dir.exist?(dir)

          @backup_dir = dir
        end
      end

      def create_current_backup_dir
        return if @current_backup_dir

        check_backup_dir
        @current_backup_dir = File.join(@backup_dir, Time.now.strftime('backup_%d%m%Y_%H%M%S'))
        try_create_dir(@current_backup_dir)
      end

      def database_backup
        create_current_backup_dir

        plugin::Database.backup_all(base.redmine_root, @current_backup_dir)
        @database_backed_up = true
      end

      def database_restore
        plugin::Database.restore_all(base.redmine_root, @current_backup_dir)
      end

      def do_full_backup
        create_current_backup_dir

        zipfile_name = File.join(@current_backup_dir, 'redmine.zip')

        Dir.chdir(base.redmine_root) do
          Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
            Dir.glob(File.join('**', '{*,.*}')).each do |entry|
              next if entry.end_with?('.') || entry.end_with?('..')

              zipfile.add(entry, entry)
            end
          end
        end

        database_backup
      end

      def do_backup
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

        database_backup
      end

  end
end
