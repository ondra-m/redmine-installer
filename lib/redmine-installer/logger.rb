require 'digest'

module RedmineInstaller
  class Logger

    def initialize
      @output = nil
      Dir::Tmpname.create('redmine_installer.log') do |tmpname, n, opts|
        mode = File::RDWR | File::CREAT | File::EXCL
        opts[:perm] = 0600
        @output = File.open(tmpname, mode, opts)
      end

      # @output = $stdout
    end

    def path
      @output.path
    end

    def finish
      close
      digest = Digest::SHA256.file(path).hexdigest
      File.open(path, 'a') { |f| f.write(digest) }
    end

    def close
      @output.flush
      @output.close
    end

    def move_to(redmine)
      close

      new_path = File.join(redmine.log_path, Time.now.strftime('redmine_installer_%d%m%Y_%H%M%S.log'))

      FileUtils.mkdir_p(redmine.log_path)
      FileUtils.mv(path, new_path)
      @output = File.open(new_path, 'a+')
    end

    def info(*messages)
      log(' INFO', *messages)
    end

    def error(*messages)
      log('ERROR', *messages)
    end

    def warn(*messages)
      log(' WARN', *messages)
    end

    def std(*messages)
      log('  STD', *messages)
    end

    def log(severity, *messages)
      messages.each do |message|
        @output.puts("#{severity}: #{message}")
      end

      @output.flush
    end

  end
end
