module PayTrace
  module Exceptions
    class Base < RuntimeError
    end

    class ValidationError < Base
    end
  end
end