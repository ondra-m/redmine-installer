module Redmine
  module Installer
    autoload :CLI,     'redmine-installer/cli'
    autoload :Task,    'redmine-installer/task'
    autoload :Install, 'redmine-installer/install'
  end
end

require 'redmine-installer/version'
