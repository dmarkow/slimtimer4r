module Faraday
  class Request::Yaml < Faraday::Middleware
    begin
      require 'yaml'
    rescue LoadError, NameError => e
      self.load_error = e
    end

    def call(env)
      if env[:body] && !env[:body].respond_to?(:to_str)
        env[:request_headers]['Content-Type'] = 'application/x-yaml'
        env[:body] = env[:body].to_yaml
      end
      @app.call env
    end
  end
end
