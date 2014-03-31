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
    PayTrace::API::Gateway.set_debug(false)
    set_mock_configuration()
  end

  it "converts a request into a URL to the api specifying the user name and password from configuration" do
    request = mock()
    request.stubs(:to_parms_string).returns("foo")

    response = mock()
    PayTrace::API::Response.stubs(:new).returns(response)

    gateway = PayTrace::API::Gateway.new(connection: connection)
    r = gateway.send_request request

    faraday.verify_stubbed_calls
    r.must_equal response
  end

  it "initializes the connection based on the configuration" do
    faraday_connection = mock
    PayTrace.configure do |config|
      config.connection = faraday_connection
    end
    gateway = PayTrace::API::Gateway.new
    gateway.connection.must_equal faraday_connection
  end

  it "sends a mock response if directed to" do
    PayTrace::API::Gateway.set_debug(true)
    request = PayTrace::API::Request.new
    gateway = PayTrace::API::Gateway.new
    canned_response = mock()
    PayTrace::API::Gateway.next_response = canned_response

    gateway.send_request(request).must_equal(canned_response)
  end

  it "doesn't send the same response twice" do
    PayTrace::API::Gateway.set_debug(true)
    request = PayTrace::API::Request.new
    gateway = PayTrace::API::Gateway.new
    canned_response = mock()
    PayTrace::API::Gateway.next_response = canned_response

    gateway.send_request(request).must_equal(canned_response)
    gateway.send_request(request).wont_equal(canned_response)
    faraday.verify_stubbed_calls
  end

  it "does not send a mock response unless in debug mode" do
    # PayTrace::API::Gateway.set_debug(true)
    request = PayTrace::API::Request.new
    gateway = PayTrace::API::Gateway.new
    canned_response = mock()
    PayTrace::API::Gateway.next_response = canned_response

    gateway.send_request(request).wont_equal(canned_response)
    faraday.verify_stubbed_calls
  end

end
