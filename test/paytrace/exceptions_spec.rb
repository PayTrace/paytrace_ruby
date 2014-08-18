require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

include PayTrace::Exceptions

describe PayTrace::Exceptions do
  describe PayTrace::Exceptions::ErrorResponse do
    it "shows the error code in to_s" do
      raw = "ERROR~779. BLOCKED - This card number has been blocked to prevent potential fraud.|"
      response = PayTrace::API::Response.new(raw)
      exception = PayTrace::Exceptions::ErrorResponse.new(response)

      exception.to_s.must_equal response.get_response()
    end
  end
end