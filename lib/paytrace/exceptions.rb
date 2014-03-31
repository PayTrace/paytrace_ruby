module PayTrace
  module Exceptions
    class Base < RuntimeError
    end

    class ValidationError < Base
    end

    class ErrorResponse < Base
    end
  end
end