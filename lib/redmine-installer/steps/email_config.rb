module Redmine::Installer::Step
  class EmailConfig < Base

    include Redmine::Installer::Helper::GenerateConfig

    def up
      create_for(plugin::EmailSending)
    end

  end
end
