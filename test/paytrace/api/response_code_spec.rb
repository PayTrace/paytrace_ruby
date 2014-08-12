require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/response_code'
require 'mocha'

describe PayTrace::API::ResponseCode do
  it "can define response codes returned from api" do
    result = PayTrace::API::ResponseCode.define("100","Password Updated")
    result.must_be_instance_of PayTrace::API::ResponseCode::PasswordUpdateSuccess
  end
  it "should contain original text" do
    result = PayTrace::API::ResponseCode.define("100", "Password Updated")
    result.text.must_equal "Password Updated"
  end
  describe "when can not find definition for code" do
    it "should return generic default response object" do
      result = PayTrace::API::ResponseCode.define("99999", "Unknown Response")
      result.must_be_instance_of PayTrace::API::ResponseCode::DefaultResponse
    end 
  end

  describe "when there is already a class created for response" do
    before do
      PayTrace::API::ResponseCode.define("77777", "Already Defined")
      @mock = mock()
      PayTrace::API::ResponseCode.set_class_factory(@mock)
    end
    it "should not be recreated" do
      @mock.expects(:create).never
      PayTrace::API::ResponseCode.define("77777", "Already Defined")
    end
  end
  
end
