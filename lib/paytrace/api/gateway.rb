require 'faraday'
require 'paytrace/api/response'
require 'paytrace/exceptions'

module PayTrace
  module API
    class Gateway
      attr_accessor :connection
      @@debug = false
      @@last_request = nil
      @@last_response = nil
      @@last_response_object = nil
      @@next_response = nil
      @@raise_exceptions = true

      def initialize(connection = nil)
        @connection = connection || PayTrace.configuration.connection
      end

      def self.debug=(enable)
        @@debug = enable
      end 

      def self.last_request
        @@last_request
      end

      def self.last_response
        @@last_response
      end

      def self.last_response_object
        @@last_response_object
      end

      def self.next_response=(next_response)
        @@next_response = next_response
      end

      def self.raise_exceptions=(raise_exceptions)
        @@raise_exceptions = raise_exceptions
      end

      def send_request(request)
        @@last_request = request.to_parms_string if @@debug
        unless (@@debug && @@next_response)
          res = @connection.post PayTrace.configuration.url, parmlist: request.to_parms_string
          raw_response = res.body
        else
          raw_response = @@next_response
        end
        
        @@last_response = raw_response
        response = PayTrace::API::Response.new(raw_response)
        @@last_response_object = response

        @@next_response = nil # just to be sure

        if @@raise_exceptions && response.has_errors?
          raise PayTrace::Exceptions::ErrorResponse.new(response.get_response())
        else
          response
        end
      end
    end
  end
end
