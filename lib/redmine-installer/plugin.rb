module Redmine::Installer
  module Plugin
    autoload :Base,     'redmine-installer/plugins/base'
    autoload :Database, 'redmine-installer/plugins/database'
  end
end
