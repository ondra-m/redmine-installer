module Redmine::Installer
  class Upgrade < Task

    STEPS = [
      step::LoadPackage,
      step::Validation,
      step::BackUp,
      step::Upgrade,
      step::MoveRedmine,
      step::SaveProfile
    ]

    attr_accessor :package
    attr_accessor :backup_dir

    def initialize(package, options={})
      self.package = package
      super(options)
    end

  end
end
