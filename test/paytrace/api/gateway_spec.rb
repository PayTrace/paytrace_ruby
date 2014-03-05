require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/gateway'

describe PayTrace::API::Gateway do
  it "converts a request into a URL to the api specifying the user name and password from configuration" do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post ("https://paytrace.com/api/default.pay") {[ 200, {}, 'foo' ]}
    end

    test = Faraday.new do |builder|
      builder.adapter :test , stubs
    end

    request = mock()
    request.stubs(:generate_paramlist).returns("foo")

    response = mock()
    PayTrace::API::Response.stubs(:new).returns(response)

    gateway = PayTrace::API::Gateway.new(connection: test)
    r = gateway.send_request request

    stubs.verify_stubbed_calls
    r.must_equal response
  end
end
