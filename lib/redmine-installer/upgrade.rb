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
