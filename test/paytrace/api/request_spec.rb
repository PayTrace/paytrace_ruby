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
    r.params[:user_name].must_equal ["request_test"]
    r.params[:password].must_equal ["request_password"]
    r.params[:terms].must_equal ["Y"]
    to_url = r.to_parms_string
    to_url.must_equal "UN~request_test|PSWD~request_password|TERMS~Y|"
  end

  it "can manually set params" do
    r = PayTrace::API::Request.new
    r.set_param(:billing_name, "Fred Jones")
    r.params[:billing_name].must_equal ["Fred Jones"]
  end

  it "can bulk set params" do
    params = {billing_name: "Fred Jones", billing_postal_code: 98133}
    r = PayTrace::API::Request.new
    r.set_params([:billing_name, :billing_postal_code], params)
    r.params[:billing_name].must_equal ["Fred Jones"]
    r.params[:billing_postal_code].must_equal [98133]
  end

  it "raises a validation exception for unknown fields" do
    r = PayTrace::API::Request.new

    -> { r.set_param(:foo, "bar") }.must_raise PayTrace::Exceptions::ValidationError
  end

  it "properly appends discretionary data" do 
    r = PayTrace::API::Request.new
    r.set_param(:billing_name, "Fred Jones")
    r.set_discretionary(:hair_color, "red")

    r.to_parms_string.must_equal "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|" +
      "BNAME~Fred Jones|hair_color~red|"
  end
end