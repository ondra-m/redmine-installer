module Redmine::Installer
  class Task

    attr_accessor :redmine_root
    attr_accessor :tmp_redmine_root
    attr_accessor :options
    attr_accessor :settings
    attr_accessor :env

    attr_reader :steps

    def initialize(options={})
      self.options = options
      self.settings = {}
      self.env = options[:env]

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
        step.ran = true
        puts
      end

      @steps.each do |id, step|
        step.final_step
      end
    rescue Redmine::Installer::Error => e
      @steps.values.reverse.each do |step|
        next unless step.ran
        step.down
      end

      $stderr.puts(ANSI.red, e.message, ANSI.clear)
      $stderr.flush
      exit(1)
    end

    # Package is required for install task and
    # upgrade with source file
    def check_package
      if package.nil?
        raise Redmine::Installer::Error, I18n.translate(:error_argument_package_is_missing)
      end
    end

    def self.step
      Redmine::Installer::Step
    end

    # Creating methods for recognition type of task
    #
    # == Examples:
    #   class Install < Task
    #   end
    #
    #   Install.new.install? #=> true
    #
    def self.inherited(child)
      method_name = "#{child.class_name.downcase}?".to_sym

      define_method(method_name) { false }
      child.send(:define_method, method_name) { true }

      super
    end

  end
end
