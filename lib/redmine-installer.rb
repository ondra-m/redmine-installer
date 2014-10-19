module Redmine
  module Installer
    autoload :CLI,     'redmine-installer/cli'
    autoload :Task,    'redmine-installer/task'
    autoload :Install, 'redmine-installer/install'

    # Root of the gem
    def self.root_path
      @root_path ||= File.expand_path('..', File.dirname(__FILE__))
    end

    # Path to locales dir
    def self.locales_path
      @locales_path ||= File.join(root_path, 'lib', 'redmine-installer', 'locales')
    end

    # Locales for I18n
    def self.locales
      @locales ||= Dir.glob(File.join(locales_path, '*.yml'))
    end

    # Default configurations fo I18n gem
    def self.set_i18n
      I18n.enforce_available_locales = false
      I18n.load_path = Redmine::Installer.locales
      I18n.locale = :en
      I18n.default_locale = :en
    end

  end
end

# Requirements
require 'pry'
require 'i18n'
require 'redmine-installer/version'

# Default configurations
Redmine::Installer.set_i18n
