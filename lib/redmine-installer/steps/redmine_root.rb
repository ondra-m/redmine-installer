module Redmine::Installer::Step
  class RedmineRoot < Base

    def up
      # Get redmine root
      base.redmine_root ||= ask(:path_for_redmine_root, default: '.')

      # Make absolute path
      base.redmine_root = File.expand_path(base.redmine_root)

      unless Dir.exist?(base.redmine_root)
        try_create_dir(base.redmine_root)
      end

      unless File.writable?(base.redmine_root)
        error t(:dir_is_not_writeable, dir: base.redmine_root)
      end
    end

    def save(configuration)
      configuration['redmine_root'] = base.redmine_root
    end

    def load(configuration)
      base.redmine_root = configuration['redmine_root']
    end

  end
end
