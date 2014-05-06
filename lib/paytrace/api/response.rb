module PayTrace
  module API
    # An object representing an API response from sending a PayTrace::API::Request with a PayTrace::API::Gateway object
    class Response
      attr_reader :values, :errors

      # Called by the PayTrace::API::Gateway object to initialize a response
      def initialize(response_string, multi_value_fields = [])
        @field_delim = "|"
        @value_delim = "~"
        @multi_value_delim = "+"
        @values = {}
        @errors = {}
        parse_response(response_string, multi_value_fields)
      end

      # Returns the response code(s) received
      def response_code
        get_response
      end

      # Returns true if the response contained any error codes
      def has_errors?
        @errors.length > 0
      end

      # Called by the initialize method
      def parse_response(response_string, multi_value_fields = [])

        if (response_string.include? "ERROR")
           return parse_errors(response_string)
        end

        pairs = response_string.split(@field_delim)
        pairs.each do |p|
          k,v = p.split(@value_delim)
          if multi_value_fields.include?(k)
            @values[k] ||= []
            @values[k] << Hash[v.split(@multi_value_delim).map {|pair| pair.split('=')}]
          else
            @values[k] = v
          end
        end
      end

      # Called by the framework in the event of an error response
      def parse_errors(response_string)
        pairs = response_string.split(@field_delim)
        pairs.each do |p|
          k,v = p.split(@value_delim)
          k = generate_error_key(k,v)
          @errors[k] = v
        end
      end

      # Internal use only
      def generate_error_key(key,value)
        #get the error number from the value
        return key +'-'+ value[/([1-9]*)/,1]
      end

      # Returns any status code(s) or error code(s) received
      def get_response()
        if has_errors?
          return get_error_response()
        end
        @values["RESPONSE"]
      end

      # Returns any error code(s) received
      def get_error_response()
        error_message = ""
        @errors.each do  |k,v|
          error_message << v + ","
        end
        error_message
      end
    end
  end
end
