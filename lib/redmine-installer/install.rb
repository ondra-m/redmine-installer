module Redmine::Installer
  class Install < Task

    STEPS = [
      step::RedmineRoot,
      step::LoadPackage,
      step::DatabaseConfig,
      step::EmailConfig,
      step::Install,
      step::MoveRedmine,
      step::WebserverConfig
    ]

    attr_accessor :package

    def initialize(package, options={})
      if package.nil?
        raise Redmine::Installer::Error, I18n.translate(:error_argument_package_is_missing)
      end

      self.package = package
      super(options)
    end

  end
end
