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
  end
end
