require 'uri'
require 'faraday'
require 'faraday_middleware'
require 'faraday/request/yaml'
require 'faraday/response/yaml'

module SlimTimer
  class Connection
    attr_accessor :connection

    def initialize(email, password, api_key)
      @api_key = api_key
      @connection ||= Faraday::Connection.new(:url => "http://slimtimer.com") do |conn|
        conn.use Faraday::Response::Yaml
        conn.use Faraday::Request::Yaml
        conn.use Faraday::Response::Mashify
        conn.adapter Faraday.default_adapter
      end
      response = @connection.post do |req|
        req.url "/users/token" #?user[email]=#{email}&user[password]=#{password}&api_key=#{api_key}"
        req.headers['Accept'] = "application/x-yaml"
        req.body = Hash.new
        req.body["user"] = {"email" => email, "password" => password}
        req.body["api_key"] = api_key
      end
      puts response.body.user_id
      @access_token = response.body.access_token
      @user_id = response.body.user_id
    end

    def get(path, params=[])
      response = @connection.get do |req|
        path = "/users/#{@user_id}/#{path}?api_key=#{@api_key}&access_token=#{@access_token}"
        params.each do |key,value|
          path << "&#{key.to_s}=#{value}" 
        end
        req.url path
        req.headers['Accept'] = "application/x-yaml"
      end
      response.body
    end
  end
end
