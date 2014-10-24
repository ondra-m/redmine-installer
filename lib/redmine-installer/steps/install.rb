module Redmine::Installer::Step
  class Install < Base

    def up
      Dir.chdir(base.tmp_redmine_root) do
        run_command(command::BUNDLE_INSTALL, :'command.bundle_install')
        run_command(command::RAKE_DB_CREATE, :'command.rake_db_create')
        run_command(command::RAKE_DB_MIGRATE, :'command.rake_db_migrate')
        run_command(command::RAKE_REDMINE_PLUGIN_MIGRATE, :'command.rake_redmine_plugin_migrate') if some_plugins?
        run_command(command::RAKE_GENERATE_SECRET_TOKEN, :'command.rake_generate_secret_token')

        # Other plugins can have post-install procedure
        plugin::RedminePlugin.all.each(&:install)
      end
    end

    private

      def some_plugins?
        Dir.glob(File.join('plugins', '*')).any?
      end

  end
end
