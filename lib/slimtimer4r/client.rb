module SlimTimer
  class Client
    attr_accessor :connection

    def initialize(email, password, api_key)
      @connection = Connection.new(email, password, api_key)
    end

    # GET /users/user_id/tasks
    def tasks(options={})
      @connection.get("tasks", options)
    end

    # GET /users/user_id/tasks/task_id
    def task(task_id)
      @connection.get("tasks/#{task_id}")
    end

    #GET /users/user_id/tasks/task_id/time_entries
    def time_entries(task_id=nil)
      if task_id
        @connection.get("tasks/#{task_id}/time_entries")
      else
        @connection.get("time_entries")
      end
    end

    #GET /users/user_id/time_entries/time_entry_id
    def time_entry(time_entry_id)
      @connection.get("time_entries/#{time_entry_id}")
    end
  end
end
