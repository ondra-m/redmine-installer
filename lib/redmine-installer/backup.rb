module Redmine::Installer
  class Backup < Task

    STEPS = [
      step::RedmineRoot,
      step::Validation,
      step::Backup
    ]

    attr_accessor :redmine_root

    def initialize(redmine_root, options={})
      self.redmine_root = redmine_root
      super(options)
    end

    def run
      Redmine::Installer::Profile.load(self, options[:profile])
      super
      Redmine::Installer::Profile.save(self) if options[:profile].nil?
    end

  end
end
