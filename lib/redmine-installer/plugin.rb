module Redmine::Installer
  module Plugin
    autoload :Base,         'redmine-installer/plugins/base'
    autoload :Database,     'redmine-installer/plugins/database'
    autoload :EmailSending, 'redmine-installer/plugins/email_sending'
  end
end
