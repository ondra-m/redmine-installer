require 'tempfile'

module Redmine::Installer
  class Install < Task

    STEPS = [
      Redmine::Installer::Step::LoadPackage
    ]

    def run
      @steps.each do |id, step|
        step.print_header
        step.up
        step.print_footer
      end
    end

  end
end
