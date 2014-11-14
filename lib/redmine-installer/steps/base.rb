module Redmine::Installer::Step
  class Base

    include Redmine::Installer::Utils

    attr_accessor :index
    attr_accessor :base
    attr_accessor :ran

    def initialize(index, base)
      self.index = index
      self.base = base
      self.ran = false
    end

    def print_title
      title  = '<bright><on_black><white>'
      title << "#{index}. "
      title << translate("step.#{self.class.class_name.underscore}.title"
        )
      title << '</white></on_black></bright>'

      say(title, 1)
    end

    def print_header
    end

    def print_footer
    end

    def final_step
    end

    def up
    end

    def down
    end

    def save(*)
    end

    def load(*)
    end

    def redmine_plugins
      @redmine_plugins ||= _redmine_plugins
    end

    private

      def _redmine_plugins
        Dir.glob(File.join(base.redmine_root, 'plugins', '*')).select do |entry|
          File.directory?(entry)
        end
      end

  end
end
