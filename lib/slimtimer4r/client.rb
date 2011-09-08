module SlimTimer
  class Client
    attr_accessor :connection

    def initialize(email, password, api_key)
      @connection = Connection.new(email, password, api_key)
    end

    def list_tasks(list_completed="yes", role="owner,coworker")
      warn "[DEPRECATION] `list_tasks` is deprecated. Please use `tasks` instead."
      tasks(:list_completed => list_completed, :role => role)
    end

    # GET /users/user_id/tasks
    def tasks(options={})
      @connection.get("tasks", options)
    end

    def show_task(task_id)
      warn "[DEPRECATION] `show_task` is deprecated. Please use `task` instead."
      task(task_id)
    end

    # GET /users/user_id/tasks/task_id
    def task(task_id)
      @connection.get("tasks/#{task_id}")
    end

    def list_timeentries(range_start = nil, range_end = nil)
      warn "[DEPRECATION] `list_timeentries` is deprecated. Please use `time_entries` instead."
      time_entries(:range_start => range_start, :range_end => range_end)
    end

    #GET /users/user_id/tasks/task_id/time_entries
    def time_entries(options={})
      range_start = format_start_time(options[:range_start])
      range_end = format_end_time(options[:range_end])
      if task_id
        @connection.get("tasks/#{task_id}/time_entries")
      else
        @connection.get("time_entries")
      end
    end

    def show_timeentry(timeentry_id)
      warn "[DEPRECATION] `show_timeentry` is deprecated. Please use `time_entry` instead."
      time_entry(timeentry_id)
    end

    #GET /users/user_id/time_entries/time_entry_id
    def time_entry(time_entry_id)
      @connection.get("time_entries/#{time_entry_id}")
    end

    private

    def format_start_time(date)
      case date
      when NilClass
        nil
      when Date
        date.strftime("%Y-%m-%dT00:00:00Z")
      else
        date.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end

    def format_end_time(date)
      case date
      when NilClass
        nil
      when Date
        date.strftime("%Y-%m-%dT00:00:00Z")
      else
        date.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end
  end
end
