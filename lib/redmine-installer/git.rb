module Redmine::Installer
  class Git
    
    def self.clone(remote, target, branch)
      success = Kernel.system("git clone --branch #{branch} --single-branch --depth 1 #{remote} #{target}")

      unless success
        error :git_repository_cannot_be_clonned
      end
    end

    def self.copy_and_fetch(repository, target)
      url = ''
      Dir.chdir(repository) do
        url = `git config --get remote.origin.url`.strip
      end

      success = Kernel.system("git clone --depth 1 --no-local #{repository} #{target}")

      unless success
        error :git_repository_cannot_be_localy_clonned
      end

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
