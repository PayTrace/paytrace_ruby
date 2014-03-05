require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/response'

describe PayTrace::API::Response do
  it "parses a successful transaction response" do
    from_server = "RESPONSE~101. Your transaction was successfully approved.|TRANSACTIONID~93|APPCODE~TAS671|APPMSG~APPROVAL TAS671 - Approved and completed|AVSRESPONSE~0|CSCRESPONSE~|"
    response = PayTrace::API::Response.new(from_server)        
    response.response_code.must_equal "101. Your transaction was successfully approved."
  end
end
