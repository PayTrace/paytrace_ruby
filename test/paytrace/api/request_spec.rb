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

  describe "#set_param" do
    it "can manually set params" do
      r = PayTrace::API::Request.new
      r.set_param(:billing_name, "Fred Jones")
      r.params[:billing_name].must_equal ["Fred Jones"]
    end

    it "invokes set_request on values sent to set_param" do
      request = PayTrace::API::Request.new

      mock = MiniTest::Mock.new
      mock.expect(:nil?, false)
      mock.expect(:set_request, nil, [request])

      request.set_param(:billing_name, mock)
    end

    it "correctly sets a value named :discretionary_data as discretionary data" do
      r = PayTrace::API::Request.new
      r.set_param(:discretionary_data, {hair_color: 'red'})

      r.params[:discretionary_data].must_equal nil
      r.discretionary_data[:hair_color].must_equal 'red'
    end

    it "properly appends discretionary data" do 
      r = PayTrace::API::Request.new
      r.set_param(:billing_name, "Fred Jones")
      r.set_discretionary(:hair_color, "red")

      r.to_parms_string.must_equal "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|" +
        "BNAME~Fred Jones|hair_color~red|"
    end

    it "raises a validation exception for unknown fields" do
      r = PayTrace::API::Request.new

      -> { r.set_param(:foo, "bar") }.must_raise PayTrace::Exceptions::ValidationError
    end
  end

  describe "#set_params" do
    it "can bulk set params" do
      params = {billing_name: "Fred Jones", billing_postal_code: 98133}
      r = PayTrace::API::Request.new
      r.set_params(params, [:billing_name, :billing_postal_code])
      r.params[:billing_name].must_equal ["Fred Jones"]
      r.params[:billing_postal_code].must_equal [98133]
    end

    it "can alias parameters in set_params" do
      params = {name: "Ron Jones", postal_code: 98134}
      r = PayTrace::API::Request.new
      r.set_params(params, [[:billing_name, :name], [:billing_postal_code, :postal_code]])
      r.params[:billing_name].must_equal ["Ron Jones"]
      r.params[:billing_postal_code].must_equal [98134]  
    end

    it "attempts to fetch parameter values from an object if supplied" do
      mock = MiniTest::Mock.new

      mock.expect(:is_a?, false, [Hash])
      mock.expect(:send, "1234 Fake Ave.", [:send, :billing_address])

      r = PayTrace::API::Request.new
      r.set_params(mock, [:billing_address])
      mock.verify
      r.params[:billing_address].must_equal ["1234 Fake Ave."]
    end

    it "raises an exception for missing required parameters" do
      params = {}
      r = PayTrace::API::Request.new

      -> { r.set_params(params, [:billing_name]) }.must_raise PayTrace::Exceptions::ValidationError
    end

    it "raises an exception for extra unrecognized parameters" do
      params = {billing_name: "1234 Fake Blvd."}
      r = PayTrace::API::Request.new

      -> { r.set_params(params, []) }.must_raise PayTrace::Exceptions::ValidationError
    end
      
    it "does not raise an exception for optional parameters" do
      params = {billing_address: "1234 Fake St."}
      r = PayTrace::API::Request.new

      # MiniTest does not have a "wont_raise" predicate, but an exception is the same as failure...
      r.set_params(params, [], [:billing_address])
    end
  end
end