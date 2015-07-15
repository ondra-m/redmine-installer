module Redmine::Installer::Step
  class EnvCheck < Base

    def prepare
      # Check if windows
      # if windows?
      #   confirm(:do_you_want_continue_if_windows, false)
      # end

      if root? && !confirm(:installer_run_as_root, false)
        error(:terminated_by_user)
      end
    end

    def up
      say '<green>... OK</green>', 1
    end

  end
end
