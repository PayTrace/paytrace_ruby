require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Configuration do
  it "grants you access to the config through the module" do
    c = PayTrace.configuration
    c.must_be_instance_of(PayTrace::Configuration)

    #Also, it should keep returning the same config
    c.must_equal(PayTrace.configuration)
  end

  it "lets you configure it by passing in blocks" do
    PayTrace.configure do |c|
      c.user_name = "demo"
      c.password = "demo"
    end 

    PayTrace.configuration.user_name.must_equal "demo"
    PayTrace.configuration.password.must_equal "demo"
  end

  it "has reasonable defaults" do
    c = PayTrace::Configuration.new
    c.domain.must_equal "paytrace.com"
    c.connection.must_be_instance_of Faraday::Connection
    c.url.must_equal "https://paytrace.com/api/default.pay"
    c.path.must_equal "api/default.pay"
  end

  it "allows you to configure what domain to point at" do
    PayTrace.configure do |config|
      config.domain = "sandbox.paytrace.com"
    end
    PayTrace.configuration.url.must_equal "https://sandbox.paytrace.com/api/default.pay"
  end

  it "allows you to change your password" do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.next_response = "RESPONSE~100. Your password was successfully updated."

    old_password = PayTrace.configuration.password
    c = PayTrace::Configuration.new
    c.update_password(new_password: 'foobar')

    PayTrace::API::Gateway.last_request.must_equal "UN~#{PayTrace.configuration.user_name}|PSWD~#{old_password}|TERMS~Y|" + 
      "METHOD~UpdatePassword|NEWPSWD~foobar|NEWPSWD2~foobar|"

    PayTrace::API::Gateway.next_response = "RESPONSE~100. Your password was successfully updated."
    c.update_password(new_password: old_password)
  end

  it "changes the config password when you successfully call update_password" do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.next_response = "RESPONSE~100. Your password was successfully updated."

    old_password = PayTrace.configuration.password
    c = PayTrace::Configuration.new
    c.update_password(new_password: 'foobar')

    PayTrace.configuration.password.must_equal 'foobar'

    PayTrace::API::Gateway.next_response = "RESPONSE~100. Your password was successfully updated."
    c.update_password(new_password: old_password)
  end
end
