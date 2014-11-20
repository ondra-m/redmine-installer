require 'fileutils'

module Redmine::Installer::Step
  class Upgrade < Base

    def up
      # Copy database.yml
      copy_config_file(plugin::Database::DATABASE_YML_PATH)

      # Copy configuration.yml
      copy_config_file(plugin::EmailSending::CONFIGURATION_YML_PATH)

      # Copy files
      FileUtils.cp_r(File.join(base.redmine_root, 'files'), base.tmp_redmine_root)

      # Copy plugins
      tmp_plugin_dir = File.join(base.tmp_redmine_root, 'plugins')
      redmine_plugins.each do |plugin|
        # Copy only plugins which are not part of package
        # - this is a upgrade so package should contains newer version
        unless Dir.exist?(File.join(tmp_plugin_dir, File.basename(plugin)))
          FileUtils.cp_r(plugin, tmp_plugin_dir)
        end
      end

      Dir.chdir(base.tmp_redmine_root) do
        command.bundle_install(base.env)
        command.rake_db_migrate(base.env)
        command.rake_redmine_plugin_migrate(base.env) if some_plugins?
        command.rake_generate_secret_token(base.env)

        # Other plugins can have post-install procedure
        plugin::RedminePlugin.all.each do |plugin|
          plugin.upgrade(base)
        end
      end

      # Delete content of redmine_root
      Dir.glob(File.join(base.redmine_root, '{*,.*}')) do |entry|
        next if entry.end_with?('.') || entry.end_with?('..')

        FileUtils.remove_entry_secure(entry)
      end
    end

    private

      def copy_config_file(relative_path)
        file = File.join(base.redmine_root, relative_path)

        if File.exist?(file)
          FileUtils.cp(file, File.join(base.tmp_redmine_root, 'config'))
        end
      end

  end
end
