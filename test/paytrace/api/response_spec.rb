require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/response'

describe PayTrace::API::Response do

  describe "When parsing records into fields that have multiple values" do
    
    it "will only split on first value delimiter" do
      from_server = "TRANSACTIONRECORD~TRANXID=1000+CC=************1234+APPMSG=FOOBAR=in email|TRANSACTIONRECORD~TRANXID=2000+CC=************5678+APPMSG=ERROR in name"
      responseObj = PayTrace::API::Response.new(from_server)
      fields = responseObj.parse_records("TRANSACTIONRECORD")
      fields[0]["APPMSG"].must_equal "FOOBAR=in email"
    end
  
    it "it does not treat the word error in the middle of sentence as error" do
      from_server = "TRANSACTIONRECORD~TRANXID=1000+CC=************1234+APPMSG=FOOBAR in email|TRANSACTIONRECORD~TRANXID=2000+CC=************5678+APPMSG=ERROR in name"
      responseObj = PayTrace::API::Response.new(from_server)
      responseObj.has_errors?.must_equal false
      responseObj.errors.length.must_equal 0
    end

  end
  
  it "parses a successful transaction response" do
    from_server = "RESPONSE~101. Your transaction was successfully approved.|TRANSACTIONID~93|APPCODE~TAS671|APPMSG~APPROVAL TAS671 - Approved and completed|AVSRESPONSE~0|CSCRESPONSE~|"
    response = PayTrace::API::Response.new(from_server)        
    response.get_response().must_equal "101. Your transaction was successfully approved."
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
    response.get_response().must_equal actual
  end

  describe "given network error" do
    it "should raise exception" do
      @from_server = "COMMERROR"
      assert_raises PayTrace::Exceptions::NetworkError do
        @response = PayTrace::API::Response.new(@from_server)
      end
    end
    it "should raise exception" do
      @from_server = "COMM ERROR"
      assert_raises PayTrace::Exceptions::NetworkError do
        @response = PayTrace::API::Response.new(@from_server)
      end
    end
  end

  describe "when getting response code" do

    describe "given no RESPONSE field" do
      before do
        @from_server = "NO RESPONSE"
        @response = PayTrace::API::Response.new(@from_server)
      end
      it "should raise exception" do
        assert_raises PayTrace::Exceptions::ValidationError do
          @response.code
        end
      end  
      describe "given has errors" do
        before do
          @from_server << "!ERROR~32. some error"
          @response = PayTrace::API::Response.new(@from_server)
        end
        it "should send back error message instead" do
          assert_raises PayTrace::Exceptions::ValidationError do
            @response.code
          end
        end
      end
    end
   
    describe "given a response with a api reponse code" do
      before do
        @from_server = "RESPONSE~100. Your password was successfully updated."
      end
      it "should be able to parse out the code" do
        response = PayTrace::API::Response.new(@from_server)
        response.code.must_equal 100
      end
    end  
  end
end
