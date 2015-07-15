##
# Backup redmine
#
# You can upgrade current redmine by archive or currently defined git repository.
# If your redmine contain plugins which are not part of new package - all these
# plugins will be kept otherwise are replaced with those from package.
#
# Final step will ask you if you want save steps configuration.
# If you say YES, configuration will be stored as profile so next time
# you can upgrade redmine faster.
#
# redmine upgrade PACKAGE --profile PROFILE_ID
# Profiles are stored on HOME_FOLDER/.redmine-installer-profiles.yml.
#
# == Steps:
# 1. Redmine root - where should be new redmine located
# 2. Load package - extract package
# 3. Validation - current redmine should be valid
# 4. Backup - backup current redmine (see backup section)
# 5. Upgrading - install commands are executed
# 6. Moving redmine - redmine is moved from temporarily folder to given redmine_root
# 7. Profile saving - generating profile (see profile section)
#
# == Usage:
#
# From archive::
#   # minimal
#   redmine upgrade PATH_TO_PACKAGE
#
#   # full
#   redmine upgrade PATH_TO_PACKAGE --env ENV1,ENV2,ENV3
#
# From git::
#   # minimal
#   redmine upgrade --source git
#
#   # full
#   redmine upgrade --source git --env ENV1,ENV2,ENV3
#
module Redmine::Installer
  class Upgrade < Task

    STEPS = [
      step::EnvCheck,
      step::RedmineRoot,
      step::LoadPackage,
      step::Validation,
      step::Backup,
      step::Upgrade,
      step::MoveRedmine
    ]

    attr_accessor :package

    def initialize(package, options={})
      self.package = package
      super(options)

      check_package if options[:source] == 'file'
    end

    def run
      Redmine::Installer::Profile.load(self, options[:profile])
      super
      Redmine::Installer::Profile.save(self) if options[:profile].nil?
    end

  end
end
