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

  end
end

##
# EasyProject
#
# http://www.easyredmine.com
#
# Easy Redmine is complex project management web application best suited to project teams between
# 10 - 100 users. Whether you manage just yourself or a huge team of software developers,
# Easy Redmine will provide all necessary project management features to complete your projects
# on time, scope and budget.
#
class EasyProject < Redmine::Installer::Plugin::RedminePlugin

  class Redmine::Installer::Command
    def rake_easyproject_install(env)
      run(RAKE, 'easyproject:install', get_rails_env(env), :'plugin.redmine_plugin.easyproject.install')
    end
  end

  RAKE_EASYPROJECT_INSTALL = 'bundle exec rake  RAILS_ENV=production'

  def self.install(base)
    command.rake_easyproject_install(base.env) if am_i_there?
  end

  def self.upgrade(base)
    install(base)
  end
end
