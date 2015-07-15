module Redmine::Installer
  module Step
    autoload :Base,            'redmine-installer/steps/base'
    autoload :LoadPackage,     'redmine-installer/steps/load_package'
    autoload :DatabaseConfig,  'redmine-installer/steps/database_config'
    autoload :EmailConfig,     'redmine-installer/steps/email_config'
    autoload :Install,         'redmine-installer/steps/install'
    autoload :MoveRedmine,     'redmine-installer/steps/move_redmine'
    autoload :WebserverConfig, 'redmine-installer/steps/webserver_config'
    autoload :Validation,      'redmine-installer/steps/validation'
    autoload :Backup,          'redmine-installer/steps/backup'
    autoload :Upgrade,         'redmine-installer/steps/upgrade'
    autoload :RedmineRoot,     'redmine-installer/steps/redmine_root'
    autoload :EnvCheck,        'redmine-installer/steps/env_check'
  end
end
