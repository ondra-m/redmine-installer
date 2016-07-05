module RedmineInstaller
  class TaskModule
    include Utils

    attr_reader :task

    def initialize(task)
      @task = task
    end

  end
end
