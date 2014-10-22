module Redmine::Installer
  class Upgrade < Task

    STEPS = [

    ]

    attr_accessor :package

    def initialize(package, redmine_root, options={})
      self.package = package
      self.redmine_root = redmine_root
      super(options)

      binding.pry unless @__binding
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
