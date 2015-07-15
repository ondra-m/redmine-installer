##
# Install redmine
#
# You can instal redmine package from archive or git.
#
# == Steps:
# 1. Redmine root - where should be new redmine located
# 2. Load package - extract package
# 3. Database configuration - you can choose type of DB which you want to use
# 4. Email sending configuration - email sending configuration
# 5. Install - install commands are executed
# 6. Moving redmine - redmine is moved from temporarily folder to given redmine_root
# 7. Webserve configuration - generating webserver configuration
#
# == Usage:
#
# From archive::
#   Supported archives are .zip and .tar.gz.
#
#   # minimal
#   redmine install PATH_TO_PACKAGE
#   redmine install REDMINE_VERSION
#
#   # full
#   redmine install PATH_TO_PACKAGE --env ENV1,ENV2,ENV3
#
module Redmine::Installer
  class Install < Task

    STEPS = [
      step::EnvCheck,
      step::RedmineRoot,
      step::LoadPackage,
      step::DatabaseConfig,
      step::EmailConfig,
      step::Install,
      step::MoveRedmine,
      step::WebserverConfig
    ]

    attr_accessor :package

    def initialize(package, options={})
      self.package = package
      super(options)

      check_package
    end

  end
end
