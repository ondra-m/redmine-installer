require 'fileutils'
require 'yaml'

module Redmine::Installer
  class Profile

    include Redmine::Installer::Utils

    CONFIG_FILE = File.join(Dir.home, '.redmine-installer-profiles.yml')
    
    def self.save(task)
      return unless check_writable
      return unless confirm(:do_you_want_save_step_for_further_use, true)

      profile = Profile.new(task)
      profile.save

      say t(:your_profile_can_be_used_as, id: profile.id), 2
    end

    def self.check_writable
      FileUtils.touch(CONFIG_FILE)
      File.writable?(CONFIG_FILE)
    end

    attr_accessor :task

    def initialize(task)
      self.task = task

      # Load profiles
      @data = YAML.load_file(CONFIG_FILE)

      # Make empty Hash if there is no profiles
      @data = {} unless @data.is_a?(Hash)
    end

    def id
      @id ||= @data.keys.max.to_i + 1
    end

    def save
      # All steps save configuration which can be use again
      configuration = {}
      task.steps.each do |_, step|
        step.save(configuration)
      end
      
      @data[id] = configuration

      File.open(CONFIG_FILE, 'w') {|f| f.puts(YAML.dump(@data))}
    end

  end
end
