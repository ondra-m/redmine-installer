require 'notifier'
require 'ansi'

module Redmine::Installer
  module Utils
    
    def self.included(base)
      base.send :extend,  Methods
      base.send :include, Methods
    end
   
    module Methods

      # =======================================================================
      # Input, output

      # Print message to stdout
      def say(message, lines=0)
        # Translate message
        if message.is_a?(Symbol)
          message = translate(message)
        end

        # Colorize message
        # colorize(message)

        $stdout.print(message)
        lines.times { $stdout.puts }
        $stdout.flush
      end

      # Instead of `super` take only what I need
      def gets
        $stdin.gets.to_s.chomp
      end

      # Asking on 1 line
      def ask(message=nil, options={})
        # Translate message
        if message.is_a?(Symbol)
          message = translate(message)
        end
        default = options[:default]

        if default
          message << " [#{default}]"
        end
        message << ': '

        say(message)
        input = gets

        # Ctrl-D or enter was pressed
        return default if input.empty?

        input
      end


      # =======================================================================
      # Localizations

      def translate(*args)
        I18n.translate(*args)
      end
      alias_method :t, :translate


    end # Methods
  end # Utils
end # Redmine::Installer
