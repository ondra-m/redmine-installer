module Redmine::Installer
  class Git
    
    # Simple git clone. Create a shallow clone with 1 revision.
    #
    # - download specific branch
    # - single branch
    # - store repository to target
    #
    def self.clone(remote, target, branch='master')
      success = Kernel.system("git clone --branch #{branch} --single-branch --depth 1 #{remote} #{target}")

      unless success
        error :git_repository_cannot_be_clonned
      end
    end

    # Git repository is locally clonned to target. On copied git is
    # executed `git fetch` (for preserve changes)
    #
    def self.copy_and_fetch(repository, target)
      url = ''
      # Store original remote url because copied repository will
      # have remote set to local repo
      Dir.chdir(repository) do
        url = `git config --get remote.origin.url`.strip
      end

      success = Kernel.system("git clone --depth 1 --no-local #{repository} #{target}")

      unless success
        error :git_repository_cannot_be_localy_clonned
      end

      # Change remote to origin and run fetch
      Dir.chdir(target) do
        Kernel.system("git remote set-url origin #{url}")
        success = Kernel.system('git fetch')
      end

      unless success
        error :git_repository_cannot_be_fetched
      end
    end

    def self.error(message)
      raise Redmine::Installer::Error, I18n.translate(message)
    end

  end
end
