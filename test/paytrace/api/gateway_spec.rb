require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/gateway'

describe PayTrace::API::Gateway do
  attr :connection, :faraday

  def set_mock_configuration
    PayTrace.configure do |config|
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post ("https://paytrace.com/api/default.pay") {[ 200, {}, 'foo' ]}
      end
      @faraday = stubs

      test = Faraday.new do |builder|
        builder.adapter :test , stubs
      end
      config.connection = test
      @connection = test
    end
  end

  before do
    set_mock_configuration()
  end

  it "converts a request into a URL to the api specifying the user name and password from configuration" do
    request = mock()
    request.stubs(:to_parms_string).returns("foo")

    gateway = PayTrace::API::Gateway.new(connection: connection)
    r = gateway.send_request request

    faraday.verify_stubbed_calls
  end

  it "initializes the connection based on the configuration" do
    faraday_connection = mock
    PayTrace.configure do |config|
      config.connection = faraday_connection
    end
    gateway = PayTrace::API::Gateway.new
    gateway.connection.must_equal faraday_connection
  end

  describe "debug mode" do
    it "sends a mock response if directed to" do
      PayTrace::API::Gateway.debug = true

      request = PayTrace::API::Request.new
      gateway = PayTrace::API::Gateway.new
      canned_response = "foobar"
      PayTrace::API::Gateway.next_response = canned_response

      gateway.send_request(request)
      PayTrace::API::Gateway.last_response.must_equal(canned_response)
    end

    it "doesn't send the same response twice" do
      PayTrace::API::Gateway.debug = true

      request = PayTrace::API::Request.new
      gateway = PayTrace::API::Gateway.new
      canned_response = "foobar"
      PayTrace::API::Gateway.next_response = canned_response

      gateway.send_request(request)
      PayTrace::API::Gateway.last_response.must_equal(canned_response)
      gateway.send_request(request)
      PayTrace::API::Gateway.last_response.wont_equal(canned_response)
      faraday.verify_stubbed_calls
    end

    it "does not send a mock response unless in debug mode" do
      PayTrace::API::Gateway.debug = false

      request = PayTrace::API::Request.new
      gateway = PayTrace::API::Gateway.new
      canned_response = "foobar"
      PayTrace::API::Gateway.next_response = canned_response

      gateway.send_request(request)
      PayTrace::API::Gateway.last_response.wont_equal(canned_response)
      faraday.verify_stubbed_calls
    end

    it "raises an ErrorResponse exception for errors" do
      PayTrace::API::Gateway.debug = true # to enable mock response
      PayTrace::API::Gateway.raise_exceptions = true

      response = "ERROR~35. Please provide a valid Credit Card Number.|ERROR~43. Please provide a valid Expiration Month.|"
      PayTrace::API::Gateway.next_response = response

      request = PayTrace::API::Request.new
      gateway = PayTrace::API::Gateway.new
      -> { gateway.send_request(request) }.must_raise PayTrace::Exceptions::ErrorResponse
    end

    it "does not raise an ErrorResponse if raise_exceptions is false" do
      PayTrace::API::Gateway.debug = true # to enable mock response
      PayTrace::API::Gateway.raise_exceptions = false

      response = "ERROR~35. Please provide a valid Credit Card Number.|ERROR~43. Please provide a valid Expiration Month.|"
      PayTrace::API::Gateway.next_response = response

      request = PayTrace::API::Request.new
      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request) # if it raises an exception, the test fails; there's no "wont_raise" in minitest
    end
  end
end
