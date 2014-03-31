require 'faraday'
require 'paytrace/api/response'

module PayTrace
  module API
    class Gateway
      attr_accessor :connection
      @@debug = false
      @@last_request = nil
      @@last_response = nil
      @@next_response = nil

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

      def self.next_response=(next_response)
        @@next_response = next_response
      end

      def send_request(request)
        @@last_request = request if @@debug
        unless (@@debug && @@next_response)
          res = @connection.post PayTrace.configuration.url, parmlist: request.to_parms_string
          response = PayTrace::API::Response.new(res.body)
        else
          response = @@next_response
        end
        
        @@last_response = response if @@debug
        @@next_response = nil # just to be sure

        response
      end
    end
  end
end
