require 'fileutils'

module Redmine::Installer::Step
  class MoveRedmine < Base

    def up
      # Move all files from tmp_redmine_root to redmine_root
      Dir.glob(File.join(base.tmp_redmine_root, '{*,.*}')) do |entry|
        next if entry.end_with?('.') || entry.end_with?('..')

        FileUtils.mv(entry, base.redmine_root)
      end

      # Delete tmp_redmine_root
      FileUtils.remove_entry_secure(base.settings[:tmpdir])

      # Change dir to redmine_root
      Dir.chdir(base.redmine_root)
    end

    def print_footer
      say '<green>... OK</green>', 1
    end

  end
end
