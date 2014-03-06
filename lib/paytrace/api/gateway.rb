require 'faraday'
require 'paytrace/api/response'

module PayTrace
  module API
    class Gateway
      attr_accessor :connection

      def initialize(connection: nil)
        @connection = connection 
        @connection ||= PayTrace.configuration.connection
      end

      def send_request(request)
        res = @connection.post PayTrace.configuration.url, parmlist: request.to_parms_string
        PayTrace::API::Response.new(res.body)
      end
    end
  end
end
