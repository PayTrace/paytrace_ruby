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
end
