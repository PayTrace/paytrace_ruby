require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/response'

describe PayTrace::API::Response do
  it "parses a successful transaction response" do
    from_server = "RESPONSE~101. Your transaction was successfully approved.|TRANSACTIONID~93|APPCODE~TAS671|APPMSG~APPROVAL TAS671 - Approved and completed|AVSRESPONSE~0|CSCRESPONSE~|"
    response = PayTrace::API::Response.new(from_server)        
    response.response_code.must_equal "101. Your transaction was successfully approved."
  end

  it "parses multiple error responses" do
    from_server ="ERROR~35. Please provide a valid Credit Card Number.|ERROR~43. Please provide a valid Expiration Month.|"
    response = PayTrace::API::Response.new(from_server)
    response.has_errors?.must_equal true
  end

  it "will can contain multiple error messages" do
    from_server ="ERROR~35. Please provide a valid Credit Card Number.|ERROR~43. Please provide a valid Expiration Month.|"
    response = PayTrace::API::Response.new(from_server)
    response.errors.length.must_equal 2
  end

  it "should create a response with all errors in it" do
    from_server ="ERROR~35. Please provide a valid Credit Card Number.|ERROR~43. Please provide a valid Expiration Month.|"
    response = PayTrace::API::Response.new(from_server)
    actual ="35. Please provide a valid Credit Card Number.,43. Please provide a valid Expiration Month.,"
    response.response_code.must_equal actual
  end


end
