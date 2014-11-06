module Redmine::Installer
  class Upgrade < Task

    STEPS = [
      step::RedmineRoot,
      step::LoadPackage,
      step::Validation,
      step::Backup,
      step::Upgrade,
      step::MoveRedmine
    ]

    attr_accessor :package

    def initialize(package, options={})
      self.package = package
      super(options)

      check_package if options[:source] == 'file'
    end

    def run
      Redmine::Installer::Profile.load(self, options[:profile])
      super
      Redmine::Installer::Profile.save(self) if options[:profile].nil?
    end

  end
end
