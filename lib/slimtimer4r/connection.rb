require 'uri'
require 'faraday_yaml'
require 'faraday_middleware'

module SlimTimer
  class Connection
    attr_accessor :connection

    def initialize(email, password, api_key)
      @api_key = api_key
      @connection ||= Faraday::Connection.new(:url => "http://slimtimer.com") do |conn|
        conn.use Faraday::Response::YAML
        conn.use Faraday::Request::YAML
        conn.use Faraday::Response::Mashify
        conn.adapter Faraday.default_adapter
      end
      response = @connection.post do |req|
        req.url "/users/token" #?user[email]=#{email}&user[password]=#{password}&api_key=#{api_key}"
        req.headers['Accept'] = "application/x-yaml"
        req.body = {"user" => {"email" => email, "password" => password}, "api_key" => api_key}
      end

      if response.body.error
        raise InvalidAuthentication if response.body.error =~ /Authentication/
        raise InvalidAPIKey if response.body.error =~ /API/
      end
      @access_token = response.body.access_token
      @user_id = response.body.user_id
    end

    def get(path, params=[])
      response = @connection.get do |req|
        req.url "/users/#{@user_id}/#{path}?api_key=#{@api_key}&access_token=#{@access_token}"
        req.headers['Accept'] = "application/x-yaml"
      end
      raise InvalidRecord if response.status == 500
      response.body
    end
  end
end
