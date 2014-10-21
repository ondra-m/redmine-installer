require 'tempfile'

module Redmine::Installer
  class Install < Task

    STEPS = [
      Redmine::Installer::Step::LoadPackage,
      Redmine::Installer::Step::DatabaseConfig,
      Redmine::Installer::Step::EmailConfig,
      Redmine::Installer::Step::Install,
      Redmine::Installer::Step::MoveRedmine,
      Redmine::Installer::Step::WebserverConfig
    ]

    attr_accessor :redmine

    def initialize(redmine, options={})
      self.redmine = redmine
      super(options)
    end

    def run
      @steps.each do |id, step|
        step.print_title
        step.print_header
        step.up
        step.print_footer
      end
    end

  end
end
