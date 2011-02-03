module SlimTimer
  class Client
    attr_accessor :connection
    def initialize
      @connection = Connection.new

    end

    def tasks(options={})
      @connection.get("tasks", options).tasks.task
    end

    def task(task_id="223710")
      @connection.get("tasks/#{task_id}").task
    end
  end
end
