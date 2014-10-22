require 'fileutils'

module Redmine::Installer::Step
  class MoveRedmine < Base

    def up
      # Move all files from tmp_redmine_root to redmine_root
      FileUtils.mv(
        Dir.glob(File.join(base.tmp_redmine_root, '*')),
        base.redmine_root
      )

      # Delete tmp_redmine_root
      FileUtils.remove_entry_secure(base.tmp_redmine_root)

      # Change dir to redmine_root
      Dir.chdir(base.tmp_redmine_roott)
    end

  end
end
