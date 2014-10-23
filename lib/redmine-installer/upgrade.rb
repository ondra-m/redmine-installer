module Redmine::Installer
  class Upgrade < Task

    STEPS = [
      step::LoadPackage,
      step::Validation,
      step::BackUp,
      step::Upgrade,
      step::MoveRedmine
    ]

    attr_accessor :package
    attr_accessor :backup_dir

    def initialize(package, options={})
      self.package = package
      super(options)
    end

    def run
      Redmine::Installer::Profile.load(self, options[:profile])
      super
      Redmine::Installer::Profile.save(self)
    end

  end
end
