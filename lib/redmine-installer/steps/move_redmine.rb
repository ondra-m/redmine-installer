require 'fileutils'

module Redmine::Installer::Step
  class MoveRedmine < Base

    def up
      # Move all files from tmp_redmine_root to redmine_root
      Dir.chdir(base.tmp_redmine_root) do
        Dir.glob('{*,.*}') do |entry|
          next if entry.end_with?('.') || entry.end_with?('..')

          FileUtils.mv(entry, base.redmine_root)
        end
      end
    end

    def print_footer
      say '<green>... OK</green>', 1
    end

  end
end
