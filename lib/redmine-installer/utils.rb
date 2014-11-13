require 'fileutils'
require 'notifier'
require 'ansi'

module Redmine::Installer
  module Utils
    
    def self.included(base)
      base.send :extend,  Methods
      base.send :include, Methods

      base.class_eval do
        self.send(:const_set, 'Git', Redmine::Installer::Git)
      end
    end

    module Methods

      # =======================================================================
      # Generals

      def plugin
        Redmine::Installer::Plugin
      end

      def command
        Redmine::Installer::Command.instance
      end

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

      # def exec(*args)
      #   Redmine::Installer::Exec.new(*args)
      # end

      # def run_command(command, title, repeatable=true)
      #   title = translate(title) if title.is_a?(Symbol)
      #   message = "--> <yellow>#{title}</yellow>"
      #   colorize(message)

      #   puts '-->'
      #   puts message
      #   puts '-->'
      #   success = Kernel.system(command)

      #   unless success
      #     if repeatable && confirm(:do_you_want_repeat_command, false)
      #       return run_command(command, title, repeatable)
      #     end
      #   end

      #   return success
      # end

      # Try create a dir
      # When mkdir raise an error (permission problem) method
      # ask user if wants exist or try again
      def try_create_dir(dir)
        begin
          FileUtils.mkdir_p(dir)
        rescue
          choices = {}
          choices[:exit] = t(:exit)
          choices[:try_again] = t(:try_again)

          answer = choose(t(:dir_not_exist_and_cannot_be_created, dir: dir), choices, default: :exit)

          case answer
          when :exit
            error ''
          when :try_again
            try_create_dir(dir)
          end
        end
      end

      # Check if there are plugins in plugin dir
      def some_plugins?
        Dir.glob(File.join('plugins', '*')).select{|record| File.directory?(record)}.any?
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

        say(message, 1) unless message.nil?
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
        puts

        # Without default is input 0
        return default if input.zero? || input > choices.size

        choices[input-1][0]
      end

      def confirm(message, default=true)
        # Translate message
        if message.is_a?(Symbol)
          message = translate(message)
        end

        # Colorize message
        colorize(message)

        yes = t(:yes_t)
        no  = t(:no_t)

        if default
          yes.upcase!
        else
          no.upcase!
        end

        message << " (#{yes}/#{no}): "

        $stdout.print(message)
        answer = gets

        return default if answer.empty?

        if answer[0].downcase == yes[0].downcase
          return true
        else
          return false
        end
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
