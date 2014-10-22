module Redmine::Installer::Plugin
  class RedminePlugin < Base

    class EasyProject < RedminePlugin

      RAKE_EASYPROJECT_INSTALL = 'bundle exec rake easyproject:install RAILS_ENV=production'

      def self.install
        run_command(RAKE_EASYPROJECT_INSTALL, t('plugin.redmine_plugin.easyproject.install'))
      end
    end

  end
end
