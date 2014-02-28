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
        PayTrace::API::Response.parse(
          @connection.post URL, parmlist: request.generate_paramlist
        )
      end
    end
  end
end
