module Redmine::Installer
  module Step
    autoload :Base,        'redmine-installer/steps/base'
    autoload :LoadPackage, 'redmine-installer/steps/load_package'
  end
end
