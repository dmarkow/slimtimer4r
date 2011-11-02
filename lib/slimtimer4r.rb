require 'slimtimer4r/connection'
require 'slimtimer4r/client'
require 'slimtimer4r/version'

module SlimTimer
  class InvalidAuthentication < StandardError; end
  class InvalidAPIKey < StandardError; end
  class InvalidRecord < StandardError; end
  
  class << self
    def new(*args)
      SlimTimer::Client.new(*args)
    end
  end
end
