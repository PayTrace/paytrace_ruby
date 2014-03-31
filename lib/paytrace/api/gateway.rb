require 'faraday'
require 'paytrace/api/response'

module PayTrace
  module API
    class Gateway
      attr_accessor :connection
      @@debug = false
      @@last_request = nil
      @@last_response = nil

      def initialize(connection: nil)
        @connection = connection || PayTrace.configuration.connection
      end

      def self.set_debug(enable = true)
        @@debug = enable
      end 

      def self.last_request
        @@last_request
      end

      def self.last_response
        @@last_response
      end

      def send_request(request)
        @@last_request = request if @@debug
        res = @connection.post PayTrace.configuration.url, parmlist: request.to_parms_string
        response = PayTrace::API::Response.new(res.body)
        @@last_response = response if @@debug

        response
      end
    end
  end
end
