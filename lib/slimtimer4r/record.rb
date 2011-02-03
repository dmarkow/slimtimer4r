module SlimTimer
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

    # TODO: Proper sanitization of dates
    # def updated_at
    #   sanitize_time(super)
    # end
    # 
    # def created_at
    #   sanitize_time(super)
    # end

    private

    def dashify(name)
      name.to_s.tr("_","-")
    end

    # This removes the usec's and adjusts the times to the local
    # time zone.
    def sanitize_time(time)
      Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec) unless time.nil?
    end

  end

end
