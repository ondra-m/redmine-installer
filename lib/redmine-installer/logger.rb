require 'digest'

module RedmineInstaller
  class Logger

    def self.verify(log_file)
      log_file = log_file.to_s

      unless File.exist?(log_file)
        puts "File '#{log_file}' does not exist."
        exit(false)
      end

      content = File.open(log_file, &:to_a)
      digest1 = content.pop
      digest2 = Digest::SHA256.hexdigest(content.join)

      if digest1 == digest2
        puts RedmineInstaller.pastel.green("Logfile is OK. Digest verified.")
      else
        puts RedmineInstaller.pastel.red("Logfile is not OK. Digest wasn't verified.")
      end
    end

    def initialize
      if ENV['REDMINE_INSTALLER_LOGFILE']
        @output = File.open(ENV['REDMINE_INSTALLER_LOGFILE'], 'w')
      else
        @output = Tempfile.create('redmine_installer.log')
      end
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

    def move_to(redmine, suffix: '%d%m%Y_%H%M%S')
      close

      new_path = File.join(redmine.log_path, Time.now.strftime("redmine_installer_#{suffix}.log"))

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
