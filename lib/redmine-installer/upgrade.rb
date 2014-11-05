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
      if package.nil?
        raise Redmine::Installer::Error, I18n.translate(:error_argument_package_is_missing)
      end

      self.package = package
      super(options)
    end

    def run
      Redmine::Installer::Profile.load(self, options[:profile])
      super
      Redmine::Installer::Profile.save(self) if options[:profile].nil?
    end

  end
end
