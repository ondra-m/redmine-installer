module Redmine::Installer::Plugin
  class RedminePlugin < Base

    # Search plugins folder
    def self.am_i_there?
      records = Dir.glob(File.join('plugins', '*'))
      records.map! do |record|
        File.basename(record)
      end

      records.include?(self.class_name.downcase)
    end

    class EasyProject < RedminePlugin

      RAKE_EASYPROJECT_INSTALL = 'bundle exec rake easyproject:install RAILS_ENV=production'

      def self.install
        if am_i_there?
          run_command(RAKE_EASYPROJECT_INSTALL, t('plugin.redmine_plugin.easyproject.install'))
        end
      end

      def self.upgrade
        install
      end
    end

  end
end
