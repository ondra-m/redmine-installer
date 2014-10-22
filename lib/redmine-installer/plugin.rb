module Redmine::Installer
  module Plugin
    autoload :Base,         'redmine-installer/plugins/base'
    autoload :Database,     'redmine-installer/plugins/database'
    autoload :EmailSending, 'redmine-installer/plugins/email_sending'
    autoload :WebServer,    'redmine-installer/plugins/web_server'
  end
end
