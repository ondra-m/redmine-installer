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
      self.package = package
      super(options)
    end

  end
end
