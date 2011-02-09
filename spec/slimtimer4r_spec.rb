require 'spec_helper'
require 'webmock/rspec'

describe SlimTimer::Client do

  it "initializes properly" do
    stub_request(:post, "http://slimtimer.com/users/token").to_return(:status => 200,
                                                                      :headers => {'Content-Type' => 'application/x-yaml'},
                                                                      :body => "---\nuser_id: 1\naccess_token: cea67ae2c4b7fa3be496f508f52aad6230b2684a")
    lambda { @st = SlimTimer::Client.new("good@example.com","secret","12345") }.should_not raise_error
  end

  it "fails to initialize with improper login info" do
    stub_request(:post, "http://slimtimer.com/users/token").to_return(:status => 500,
                                                                      :headers => {'Content-Type' => 'application/x-yaml'},
                                                                      :body => "---\n:error: Authentication failed")
    lambda { @st = SlimTimer::Client.new("bad@example.com","secret","12345") }.should raise_error(SlimTimer::InvalidAuthentication)
  end

  it "fails to initialize with an improper api key" do
    stub_request(:post, "http://slimtimer.com/users/token").to_return(:status => 500,
                                                                      :headers => {'Content-Type' => 'application/x-yaml'},
                                                                      :body => "---\n:error: API Key is invalid")
    lambda { @st = SlimTimer::Client.new("good@example.com", "secret", "12346") }.should raise_error(SlimTimer::InvalidAPIKey)
  end

  context "Tasks" do
    before(:all) do
      stub_request(:post, "http://slimtimer.com/users/token").to_return(:status => 200,
                                                                        :headers => {'Content-Type' => 'application/x-yaml'},
                                                                        :body => "---\nuser_id: 1\naccess_token: cea67ae2c4b7fa3be496f508f52aad6230b2684a")
      @st = SlimTimer::Client.new("good@example.com","secret","12345")
    end

    it "retrieves a list of tasks" do
      stub_request(:get, "http://slimtimer.com/users/1/tasks").
        with(:query => {:api_key => "12345", :access_token => "cea67ae2c4b7fa3be496f508f52aad6230b2684a"}).
        to_return(:status => 200,
                  :headers => {'Content-Type' => 'application/x-yaml'},
                  :body => File.read("./spec/yaml/task_list.yaml"))
      @tasks = @st.tasks
      @tasks.length.should == 2
      @tasks.first.name.should == "First Task"
      @tasks.last.owners.first.name.should == "Sample User"
    end

    it "retrieves a task" do
      stub_request(:get, "http://slimtimer.com/users/1/tasks/100").
        with(:query => {:api_key => "12345", :access_token => "cea67ae2c4b7fa3be496f508f52aad6230b2684a"}).
        to_return(:status => 200,
                  :headers => {'Content-Type' => 'application/x-yaml'},
                  :body => File.read("./spec/yaml/task.yaml"))
      @task = @st.task(100)
      @task.name.should == "First Task"
    end
  end
end
