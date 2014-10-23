module Redmine::Installer
  class Task

    attr_accessor :redmine_root
    attr_accessor :tmp_redmine_root
    attr_accessor :options
    attr_accessor :settings

    attr_reader :steps

    def initialize(options={})
      self.options = options
      self.settings = {}
      
      # Initialize steps for task
      @steps = {}
      index = 1
      self.class::STEPS.each do |step|
        @steps[index] = step.new(index, self)
        index += 1
      end
    end

    def run
      @steps.each do |id, step|
        step.print_title
        step.print_header
        step.up
        step.print_footer
        puts
      end

      @steps.each do |id, step|
        step.final_step
      end
    end

    def self.step
      Redmine::Installer::Step
    end

  end
end
