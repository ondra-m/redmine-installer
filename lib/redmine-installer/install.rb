require 'tempfile'

module Redmine::Installer
  class Install < Task

    STEPS = [
      Redmine::Installer::Step::LoadPackage
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
