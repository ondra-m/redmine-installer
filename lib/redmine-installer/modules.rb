module RedmineInstaller
  class Modules
    include Utils

    attr_reader :task

    def initialize(task)
      @task = task
    end

  end
end
