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
      # Generals

      def error(message)
        raise Redmine::Installer::Error, message
      end


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

      # Colorize text based on XML marks
      #
      # == Examples:
      #   colorize("<bright><on_black><white>text</white></on_black></bright>")
      #   # => "\e[1m\e[40m\e[37mtext\e[0m\e[0m\e[0m"
      #
      def colorize(text)
        return unless text.is_a?(String)

        key = '([a-zA-Z0-9_]+)'

        text.gsub!(/<#{key}>/) do
          if ANSI::CHART.has_key?($1.to_sym)
            ANSI.send($1)
          else
            "<#{$1}>"
          end
        end
        text.gsub!(/<\/#{key}>/) do
          if ANSI::CHART.has_key?($1.to_sym)
            ANSI.clear
          else
            "</#{$1}>"
          end
        end
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


      # =======================================================================
      # Notifications

      def notif(title, message=nil, image=nil)
        return unless Redmine::Installer.config.notif

        thread = ::Notifier.notify(
          title: title.to_s,
          message: message.to_s,
          image: image.to_s
        )
        thread.join
      end

    end # Methods
  end # Utils
end # Redmine::Installer
