require 'commander'

module Commander
  module UI
    # Disable paging for 'classic' help
    def self.enable_paging
    end
  end
end

module RedmineInstaller
  class CLI
    include Commander::Methods

    def run
      program :name, 'Ruby installer'
      program :version, RedmineInstaller::VERSION
      program :description, 'Easy way how install/upgrade redmine or plugin.'

      global_option('-d', '--debug', 'Logging message to stdout'){ $DEBUG = true }
      global_option('-s', '--silent', 'Be less version in outpur') { $SILENT_MODE = true }
      default_command :help


      # --- Install -----------------------------------------------------------
      command :install do |c|
        c.syntax = 'install [PACKAGE] [REDMINE_ROOT] [options]'
        c.description = 'Install redmine or easyredmine'

        c.example 'Install from archive',
                  'redmine install ~/REDMINE_PACKAGE.zip'
        c.example 'Install specific version from internet',
                  'redmine install v3.1.0'
        c.example 'Install package to new dir',
                  'redmine install ~/REDMINE_PACKAGE.zip redmine_root'

        c.option '--enable-user-root', 'Skip root as root validation'
        c.option '--bundle-options', String, 'Add options to bundle command'

        c.action do |args, options|
          options.default(enable_user_root: false)

          RedmineInstaller::Install.new(args[0], args[1], options.__hash__).run
        end
      end
      alias_command :i, :install


      # --- Upgrade -----------------------------------------------------------
      command :upgrade do |c|
        c.syntax = 'upgrade [PACKAGE] [REDMINE_ROOT] [options]'
        c.description = 'Upgrade redmine or easyredmine'

        c.example 'Upgrade with new package',
                  'redmine upgrade ~/REDMINE_PACKAGE.zip'
        c.example 'Upgrade',
                  'redmine upgrade ~/REDMINE_PACKAGE.zip redmine_root'

        c.option '--enable-user-root', 'Skip root as root validation'
        c.option '--bundle-options', String, 'Add options to bundle command'
        c.option '-p', '--profile PROFILE_ID', Integer, 'Use saved profile'

        c.action do |args, options|
          options.default(enable_user_root: false)

          RedmineInstaller::Upgrade.new(args[0], args[1], options.__hash__).run
        end
      end
      alias_command :u, :upgrade


       # --- Verify log -------------------------------------------------------
       command :'verify-log' do |c|
         c.syntax = 'verify-log LOGFILE'
         c.description = 'Verify redmine installer log file'

         c.example 'Verify log',
                   'redmine verify-log LOGFILE'

         c.action do |args, _|
           RedmineInstaller::Logger.verify(args[0])
         end
       end

      run!
    end

  end
end
