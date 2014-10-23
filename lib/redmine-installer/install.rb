module Redmine::Installer
  class Install < Task

    STEPS = [
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

    def run
      @steps.each do |id, step|
        step.print_title
        step.print_header
        step.up
        step.print_footer
        puts
      end
    end

  end
end
