require 'childprocess'

class RedmineInstallerProcess

  attr_reader :stdout, :last_get_return

  def initialize(command, args)
    tempfile_out = Tempfile.new('redmine-installer-out')
    tempfile_err = Tempfile.new('redmine-installer-err')

    tempfile_out.sync = true
    tempfile_err.sync = true

    @process = ChildProcess.build('bin/redmine', command, *args)
    @process.io.stdout = tempfile_out
    @process.io.stderr = tempfile_err
    @process.environment['REDMINE_INSTALLER_SPEC'] = '1'
    @process.environment['REDMINE_INSTALLER_LOGFILE'] = File.expand_path(File.join(File.dirname(__FILE__), 'log.log'))
    @process.duplex = true
    @process.detach = true

    # Because of file description is shared with redmine installer
    # so changing posiiotn has effect fot both processes
    @stdout = File.open(tempfile_out.path)

    @last_get_return = ''
    @buffer = ''
    @seek = 0
  end

  def start
    @process.start
  end

  def stop
    @process.stop
  end

  def write(text)
    @process.io.stdin << (text + "\n")
  end

  def get(*args)
    @last_get_return = _get(*args)
  end

  private

    # max_wait in s
    def _get(text, max_wait: 5)
      wait_to = Time.now + max_wait
      while Time.now < wait_to
        @buffer << @stdout.read
        index = @buffer.rindex(text)

        if index
          break
          # return @buffer.slice!(0, index+text.size)
        else
          sleep 0.5
        end
      end

      @buffer
    end

end
