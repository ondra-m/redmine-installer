module Redmine::Installer::Step
  class Install < Base

    def up
      Dir.chdir(base.tmp_redmine_root) do
        command.bundle_install(base.env)

        return if base.settings[:skip_migration]

        command.rake_db_create(base.env)
        command.rake_db_migrate(base.env)
        command.rake_redmine_plugin_migrate(base.env) if some_plugins?
        command.rake_generate_secret_token(base.env)

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
