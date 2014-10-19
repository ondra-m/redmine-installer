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

      def error(*args)
        # Translate message
        if args.first.is_a?(Symbol)
          message = translate(*args)
        else
          message = args.first
        end

        # Colorize message
        colorize(message)

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
        colorize(message)

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

        text.gsub!(/<([a-zA-Z0-9_]+)>/) do
          if ANSI::CHART.has_key?($1.to_sym)
            ANSI.send($1)
          else
            "<#{$1}>"
          end
        end
        text.gsub!(/<\/([a-zA-Z0-9_]+)>/) do
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

        if !options[:without_colon]
          message << ': '
        end

        say(message)
        input = gets

        # Ctrl-D or enter was pressed
        return default if input.empty?

        input
      end

      # User can choose from selection
      def choose(message, choices, options={})
        choices = choices.to_a
        default = options[:default]
        index = 1
        choices.each do |(key, message)|
          if key == default
            pre = '*'
          else
            pre = ' '
          end

          say(" #{pre}#{index}) #{message}", 1)
          index += 1
        end
        
        input = ask('> ', without_colon: true).to_i

        # Without default is input 0
        return default if input.zero? || input > choices.size

        choices[input-1][0]
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
