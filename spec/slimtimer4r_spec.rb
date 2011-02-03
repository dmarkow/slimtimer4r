require 'spec_helper'

describe SlimTimer do

  it "initializes properly" do
    response_data = File.read("spec/support/responses/valid_login.yaml")
    stub_request(:post, "http://slimtimer.com/users/token").to_return(:body => response_data)
    @st = SlimTimer::Client.new("good@example.com","secret","12345")
    @st.access_token.should_not == nil
  end
  
  it "fails to initialize with improper login info" do
    stub_request(:post, "http://slimtimer.com/users/token").to_return(:status => 500)
    lambda { @st = SlimTimer::Client.new("bad@example.com","secret","12345") }.should raise_error
  end

end
