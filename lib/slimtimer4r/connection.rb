require 'uri'
require 'faraday'
require 'faraday_middleware'

module SlimTimer
  class Connection
    attr_accessor :connection

    def initialize(options = {})
      @connection ||= Faraday::Connection.new(:url => "http://slimtimer.com") do |conn|
        conn.use Faraday::Response::ParseXml
        conn.use Faraday::Response::Mashify
        conn.adapter Faraday.default_adapter
      end
      response = @connection.post do |req|
        req.url "/users/token?user[email]=#{options[:email]}&user[password]=#{options[:password]}&api_key=#{options[:api_key]}"
        req.headers['Accept'] = "application/xml"
      end
      @access_token = response.body.response.access_token
      @user_id = response.body.response.user_id
    end

    def get(path, params)
      response = @connection.get do |req|
        path = "/users/#{@user_id}/#{path}?api_key=#{options[:api_key]}&access_token=#{@access_token}"
        params.each do |key,value|
          path << "&#{key.to_s}=#{value}" 
        end
        req.url path
        req.headers['Accept'] = "application/xml"
      end
      response.body
    end
  end
end
