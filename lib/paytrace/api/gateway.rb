require 'faraday'
require 'paytrace/api/response'

module PayTrace
  module API
    class Gateway
      DOMAIN = "paytrace.com"
      API_ROOT = "api/default.pay"
      URL = "https://#{DOMAIN}/#{API_ROOT}"

      def initialize(connection: Faraday.new)
        @connection = connection
      end

      def send_request(request)
        res = @connection.post URL, parmlist: request.to_parms_string
        PayTrace::API::Response.new(res.body)
      end
    end
  end
end
