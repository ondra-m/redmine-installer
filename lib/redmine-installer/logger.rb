module RedmineInstaller
  class Logger

    def initialize
      # @output = Tempfile.new('redmine_installer.log')
      # @output = $stdout
      @output = File.open('log.out', 'w+')
    end

    def close
      @output.flush
      @output.close
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
