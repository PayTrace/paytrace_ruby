module PayTrace
  # Container module for custom PayTrace exceptions
  module Exceptions
    # Base PayTrace exception object
    class Base < RuntimeError
    end

    # Raised when an unknown field is sent, or an incorrect value is used
    class ValidationError < Base
    end

    # Raised by default when an error response is returned from the server
    class ErrorResponse < Base
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def to_s
        @response.get_response()
      end
    end
  end
end