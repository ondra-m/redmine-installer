require 'open3'

##
# Executions commands with timer and error handling
#
module Redmine::Installer
  class Exec

    include Redmine::Installer::Utils

    REFRESH_TIMER = 1 # in s

    attr_reader :stdout, :stderr

    def initialize(command, title=nil, timer=true)
      @command = command

      with_title(title)
      with_timer(timer)
    end

    def with_title(title)
      if title.is_a?(Symbol)
        title = I18n.translate(title)
      end

      @title = title
      self
    end

    def with_timer(yes_no)
      if $stdout.tty?
        @with_timer = yes_no
      else
        @with_timer = false
      end
      self
    end

    def run(repeatable=false)
      show_title

      Open3.popen3(@command) do |stdin, stdout, stderr, wait_thr|
        # log = StringIO.new
        # redirect_stream(stdout, log)
        # redirect_stream(stderr, log)

        # For example: rake db:create can ask for root login
        # if current setting does not work
        stdin.close

        exit_status = wait_thr.value
        @stdout = stdout.read
        @stderr = stderr.read

        stop_timer
        if exit_status.success?
          print_result(true)
          @return_value = true
        else
          print_result(false)
          @return_value = false
          # raise Redmine::Installer::Error, stderr.read
        end
      end

      if !@return_value && repeatable && repeat?
        return run(repeatable)
      end

      return @return_value
    ensure
      stop_timer
    end

    def repeatable_run
      run
    rescue => e
      if confirm(:error_occured_repeat)
        repeatable_run
      else
        # Stop all others command
        raise Redmine::Installer::Error, e.message
      end
    end

    private

      def repeat?
        confirm(:do_you_want_repeat_command, false)
      end

      def show_title
        if @with_timer
          @timer = start_timer
        else
          $stdout.print(@title)
        end
      end

      def start_timer
        Thread.new do
          counter = 0

          loop {
            hours, seconds = counter.divmod(3600)
            minutes, seconds = seconds.divmod(60)

            printf "[%02d:%02d:%02d] %s\r", hours, minutes, seconds, @title
            counter += REFRESH_TIMER
            sleep(REFRESH_TIMER)
          }
        end
      end

      def stop_timer
        if @timer
          @timer.kill

          # Clean line
          print ' ' * 100
          print "\r"
        end
      end

      def print_result(ok=true)
        if ok
          out = $stdout
          message = '... OK'
        else
          out = $stderr
          message = '... FAIL'
        end

        if @with_timer
          out.puts("#{@title} #{message}")
        else
          out.print(message)
        end

        out.flush
      end

      def redirect_stream(stream, out)
        Thread.new do
          while (line = stream.gets)
            out.puts(line)
          end
        end
      end

  end
end
