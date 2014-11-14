##
# Backup redmine
#
# Usage: `redmine backup`
#
# == Steps:
# 1. Redmine root - where should be new redmine located
# 2. Validation - current redmine should be valid
# 3. Backup - backup current redmine (see backup section)
# 4. Profile saving - generating profile (see profile section)
#
# == Types:
#
# Full backup::
#   archive full redmine_root folder with all you databases defined at config/database.yml
#
# Backup  archive::
#   - files folder
#   - config/database.yml, config/configuration.yml
#   - databases
#
# Only database::
#   archive only databases
#
module Redmine::Installer
  class Backup < Task

    STEPS = [
      step::RedmineRoot,
      step::Validation,
      step::Backup
    ]

    attr_accessor :redmine_root

    def initialize(redmine_root, options={})
      self.redmine_root = redmine_root
      super(options)
    end

    def run
      Redmine::Installer::Profile.load(self, options[:profile])
      super
      Redmine::Installer::Profile.save(self) if options[:profile].nil?
    end

  end
end
