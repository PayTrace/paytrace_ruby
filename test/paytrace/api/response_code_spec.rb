require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/response_code'

describe PayTrace::API::ResponseCode do
  it "can define response codes returned from api" do
    result = PayTrace::API::ResponseCode.define("100","Password Updated")
    result.must_be_instance_of PayTrace::API::ResponseCode::PasswordUpdateSuccess
  end
  it "should contain original text" do
    result = PayTrace::API::ResponseCode.define("100", "Password Updated")
    result.text.must_equal "Password Updated"
  end
end
