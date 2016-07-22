require 'fileutils'
require 'tempfile'
require 'ostruct'
require 'tmpdir'
require 'pastel'
require 'yaml'

require 'tty-progressbar'
require 'tty-spinner'
require 'tty-prompt'

require 'pry'

module RedmineInstaller
  # Includes
  autoload :CLI, 'redmine-installer/cli'
  autoload :Task, 'redmine-installer/task'
  autoload :Install, 'redmine-installer/install'
  autoload :Utils, 'redmine-installer/utils'
  autoload :Logger, 'redmine-installer/logger'
  autoload :TaskModule, 'redmine-installer/task_module'
  autoload :Environment, 'redmine-installer/environment'
  autoload :Redmine, 'redmine-installer/redmine'
  autoload :Package, 'redmine-installer/package'
  autoload :Database, 'redmine-installer/database'
  autoload :Configuration, 'redmine-installer/configuration'
  autoload :Upgrade, 'redmine-installer/upgrade'
  autoload :Command, 'redmine-installer/command'
  autoload :Profile, 'redmine-installer/profile'

  # Settings
  MIN_SUPPORTED_RUBY = '2.0.0'

  def self.logger
    @logger ||= RedmineInstaller::Logger.new
  end

  def self.prompt
    @prompt ||= TTY::Prompt.new
  end

  def self.pastel
    @pastel ||= Pastel.new
  end

  def self.print_logo
    puts <<-PRINT
                __      _
    _______ ___/ /_ _  (_)__  ___
   / __/ -_) _  /  ' \\/ / _ \\/ -_)
  /_/  \\__/\\_,_/_/_/_/_/_//_/\\__/


  Powered by EasyRedmine

    PRINT
  end
end


# Requirements
require 'redmine-installer/version'
require 'redmine-installer/errors'

# Patches
require 'redmine-installer/patches/tty'

if ENV['REDMINE_INSTALLER_SPEC']
  require 'redmine-installer/spec/spec'
end

Kernel.at_exit do
  RedmineInstaller.logger.finish
end

# Log any errors before exit
# Kernel.at_exit do
#   logger = RedmineInstaller.logger
#
#   if $!.nil?
#     logger.info 'Ends successfully'
#   else
#     # Is already logged
#     unless $!.is_a?(RedmineInstaller::Error)
#       logger.error $!.message
#       logger.error $!.backtrace
#     end
#   end
#
#   logger.close
# end

# Signal.trap('SIGINT') do
#   if $REDMINE_INT
#     exit 1
#   else
#     puts
#     puts RedmineInstaller.pastel.bold('You sent terminate signal. Press again to cancel installer.')
#     puts
#     $REDMINE_INT = true
#   end
# end
