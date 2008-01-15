require 'yaml'
require 'net/http'

class SlimTimer
  VERSION = '0.2.2'

  #
  # The Record class is used to encapsulate the data returned from the SlimTimer API. This allows access 
  # to hash key/value pairs using the @entry.task.name format rather than @entry["task"]["name"].
  # 
  class Record
    attr_reader :type, :hash

    def initialize(type, hash)
      @type = type
      @hash = hash
    end

    # Checks to see if one of the values of the hash is another hash, and if so, changes it to a Record object. This allows you to use time_entry.task.name instead of time_entry.task["name"]
    def [](name)
      case @hash[name]
      when Hash then
        @hash[name] = (@hash[name].keys.length == 1 && Array === @hash[name].values.first) ? @hash[name].values.first.map { |v| Record.new(@hash[name].keys.first, v) } : Record.new(name, @hash[name])
      else
        @hash[name]
      end
    end

    def id
      @hash["id"]
    end

    def attributes
      @hash.keys
    end

    def respond_to?(sym)
      super || @hash.has_key?(sym)
    end

    # Used to convert an unknown method into a hash key. For example, item.user_id would become item["user_id"]
    def method_missing(sym, *args)
      if args.empty? && !block_given? && respond_to?(sym.to_s)
        self[sym.to_s]
      else
        super
      end
    end

    def to_s
      "\#<Record(#{@type}) #{@hash.inspect[1..-2]}>"
    end

    def inspect
      to_s
    end

    private

    def dashify(name)
      name.to_s.tr("_","-")
    end
  end

  attr_accessor :email, :password, :api_key, :user_id, :access_token, :request

  # Creates a new SlimTimer object and obtains the +access_token+ and +user_id+ from the SlimTimer API by sending your +email+, +password+, and +api_key+. Raises a _RuntimeError_ if it can't authenticate.
  # 
  #   slim_timer = SlimTimer.new("person@example.com", "password", "12345")
  #     => #<SlimTimer:0x68bca8 @password="password"...>
  # 
  #   slim_timer = SlimTimer.new("bademail@example.com", "badpassword", "12345")
  #     => RuntimeError: Error occurred (500)
  def initialize(email, password, api_key)
    @email, @password, @api_key = email, password, api_key
    connect
    get_token
  end

  # Returns an array of Record objects, each representing a task. Returns an empty array if nothing is found.
  #
  # Options:
  # <tt>show_completed</tt>::          Include completed tasks. Specify +only+ to only include the completed tasks. Valid options are +yes+, +no+, and +only+. Default is +yes+.
  # <tt>role</tt>::                    Include tasks where the user's role is one of the roles given (comma delimited). Valid options include +owner+, +coworker+, and +reporter+. Default is +owner,coworker+.
  def list_tasks(show_completed="yes", role="owner,coworker")
    request("get", "#{@user_id}/tasks?api_key=#{@api_key}&access_token=#{@access_token}&show_completed=#{show_completed}&role=#{role}", "Tasks")
  end

  # Returns a specific task as a Record object. Returns _nil_ if the record is not found.
  #
  # Options:
  # <tt>task_id</tt>:: The id of the task you would like to retrieve.
  def show_task(task_id)
    request("get", "#{@user_id}/tasks/#{task_id}?api_key=#{@api_key}&access_token=#{@access_token}", "Task")
  end

  def delete_task(task_id)
    request("delete", "#{@user_id}/tasks/#{task_id}?api_key=#{@api_key}&access_token=#{@access_token}", "Task")
  end

  def create_task(name, tags=nil, coworker_emails=nil, reporter_emails=nil, completed_on=nil)
    request("post", "#{@user_id}/tasks", {"access_token" => @access_token, "api_key" => @api_key, "task" => {"name" => name, "tags" => tags, "coworker_emails" => coworker_emails, "reporter_emails" => reporter_emails, "completed_on" => completed_on}}, "Task")
  end

  def update_task(task_id, name, tags=nil, coworker_emails=nil, reporter_emails=nil, completed_on=nil)
    request("put", "#{@user_id}/tasks/#{task_id}", {"access_token" => @access_token, "api_key" => @api_key, "task" => {"name" => name, "tags" => tags, "coworker_emails" => coworker_emails, "reporter_emails" => reporter_emails, "completed_on" => completed_on}}, "Task")
  end

  # Returns an array of Record objects, each representing a time entry. Returns an empty array if nothing is found.
  #
  # Options:
  # <tt>range_start</tt>:: Only include entries after this time. Takes either a Date 
  #                        or Time object as a parameter. If a Date object is used, 
  #                        it will append a time of 00:00:00 to the request. Default 
  #                        is +nil+, meaning there is no start range.
  # <tt>range_end  </tt>:: Only include entries before this time. Takes either a Date 
  #                        or Time object as a parameter. If a Date object is used, 
  #                        it will append a time of 23:59:59 to the request. Default 
  #                        is +nil+, meaning there is no end range.
  def list_timeentries(range_start=nil, range_end=nil)
    if range_start.is_a?(Date)
      range_start = range_start.strftime("%Y-%m-%dT00:00:00Z")
    else
      range_start = range_start.strftime("%Y-%m-%dT%H:%M:%SZ") unless range_start.nil?
    end
    if range_end.is_a?(Date)
      range_end = range_end.strftime("%Y-%m-%dT23:59:59Z")
    else
      range_end = range_end.strftime("%Y-%m-%dT%H:%M:%SZ") unless range_end.nil?
    end
    request("get", "#{@user_id}/time_entries?api_key=#{@api_key}&access_token=#{@access_token}&range_start=#{range_start}&range_end=#{range_end}", "TimeEntries")
  end

  def update_timeentry(timeentry_id, start_time, duration_in_seconds, task_id, end_time, tags=nil, comments=nil, in_progress=nil)
    start_time = start_time.strftime("%Y-%m-%dT%H:%M:%SZ")
    end_time = end_time.strftime("%Y-%m-%dT%H:%M:%SZ") unless end_time.nil?

    # add the default params
    params = {
      "start_time" => start_time,
      "duration_in_seconds" => duration_in_seconds,
      "task_id" => task_id,
      "end_time" => end_time,
    }

    # only add the applicable params
    params.merge!({"tags" => tags}) unless tags.nil?
    params.merge!({"comments" => comments}) unless comments.nil?
    params.merge!({"in_progress" => in_progress}) unless in_progress.nil?


    request("put", "#{@user_id}/time_entries/#{timeentry_id}", {"access_token" => @access_token, "api_key" => @api_key, "time_entry" => params}, "TimeEntry")
  end

  def create_timeentry(start_time, duration_in_seconds, task_id, end_time, tags=nil, comments=nil, in_progress=nil)
    start_time = start_time.strftime("%Y-%m-%dT%H:%M:%SZ")
    end_time = end_time.strftime("%Y-%m-%dT%H:%M:%SZ") unless end_time.nil?

    # add the default params
    params = {
      "start_time" => start_time,
      "duration_in_seconds" => duration_in_seconds,
      "task_id" => task_id,
      "end_time" => end_time,
    }

    # only add the applicable params
    params.merge!({"tags" => tags}) unless tags.nil?
    params.merge!({"comments" => comments}) unless comments.nil?
    params.merge!({"in_progress" => in_progress}) unless in_progress.nil?


    request("post", "#{@user_id}/time_entries", {"access_token" => @access_token, "api_key" => @api_key, "time_entry" => params}, "TimeEntry")
  end

  def show_timeentry(timeentry_id)
    request("get", "#{@user_id}/time_entries/#{timeentry_id}?api_key=#{@api_key}&access_token=#{@access_token}", "TimeEntry")
  end

  def delete_timeentry(timeentry_id)
    request("delete", "#{@user_id}/time_entries/#{timeentry_id}?api_key=#{@api_key}&access_token=#{@access_token}", "TimeEntry")
  end


  private
  def get_token
    values = request("post", "token", {"user" => {"email" => @email, "password" => @password}, "api_key" => @api_key})
    @access_token = values.access_token
    @user_id = values.user_id
  end

  def connect
    @connection = Net::HTTP.new("www.slimtimer.com", 80)
  end

  def request(method, path, parameters = {}, type="Result")
    method.downcase!
    if !['post','get','delete','put'].include?(method)
      raise "Error: bad method parameter"
    end
    if %w(get delete).include?(method)
      response = @connection.send(method, "/users/#{path}", {"Accept" => "application/x-yaml"})
    else
      response = @connection.send(method, "/users/#{path}", parameters.to_yaml, {"Content-Type" => "application/x-yaml", "Accept" => "application/x-yaml"})
    end

    if response.code == "200"

      # If this was a delete request, return true
      if method == 'delete'
        true
      else
        result = YAML::load(response.body)
        if result.is_a?(Array)
          result.map { |row| Record.new(type, row) }
        else
          Record.new(type, result)
        end
      end
    elsif response.code == "404"
      method == 'get' ? nil : false
    else
      raise "Error occurred (#{response.code}): #{response.body}"
    end
  end

end

