require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/request'

describe PayTrace::API::Request do
  before do
    PayTrace.configure do |config|
      config.user_name = "test"
      config.password = "test"
    end
  end

  it "sets the user name, password, and terms parameters from the configuration file" do
    #override to validate
    PayTrace.configure do |config|
      config.user_name = "request_test"
      config.password = "request_password"
    end

    r = PayTrace::API::Request.new
    r.params[:user_name].must_equal "request_test"
    r.params[:password].must_equal "request_password"
    r.params[:terms].must_equal "Y"
    to_url = r.to_parms_string
    to_url.must_equal "UN~request_test|PSWD~request_password|TERMS~Y|"
  end

  it "can manually set params" do
    r = PayTrace::API::Request.new
    r.set_param(:foo, "bar")
    r.params[:foo].must_equal "bar"
  end
end