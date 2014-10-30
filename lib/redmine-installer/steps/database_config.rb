module Redmine::Installer::Step
  class DatabaseConfig < Base

    include Redmine::Installer::Helper::GenerateConfig

    def up
      if create_for(plugin::Database)
        # continue
      else
        base.settings[:skip_migration] = true
      end
    end

  end
end
