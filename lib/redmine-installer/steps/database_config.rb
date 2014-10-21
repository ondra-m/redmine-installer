module Redmine::Installer::Step
  class DatabaseConfig < Base

    include Redmine::Installer::Helper::GenerateConfig

    def up
      create_for(plugin::Database)
    end

  end
end
