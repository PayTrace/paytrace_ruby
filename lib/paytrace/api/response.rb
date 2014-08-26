module PayTrace
  module API
    # An object representing an API response from sending a PayTrace::API::Request with a PayTrace::API::Gateway object
    class Response
      # :nodoc:
      attr_reader :values, :errors
      # :doc

      # Called by the PayTrace::API::Gateway object to initialize a response
      def initialize(response_string)
        @field_delim = "|"
        @value_delim = "~"
        @multi_value_delim = "+"
        @values = {}
        @errors = {}

        if response_string.include? 'COMMERROR' or response_string.include? 'COMM ERROR' 
          raise PayTrace::Exceptions::NetworkError, "Request was not processed due to a connectivity issue."
        end
        parse_response(response_string)
      end

      # Returns true if the response contained any error codes
      def has_errors?
        @errors.length > 0
      end

      # gets the API response code from the response.  there should be only be one if there are no errors.
      def code
        if !@values.has_key? 'RESPONSE'
          if has_errors? 
            raise PayTrace::Exceptions::ValidationError, get_error_response
          else
            raise PayTrace::Exceptions::ValidationError, "missing response field"
          end
        end
        code = parse_code(@values["RESPONSE"])
        code.first
      end

      # given a field name, splits the data in that value into an array of record hashes
      def parse_records(field_name)
        records = []

        [@values[field_name]].flatten.each do |raw_record|
          records << Hash[raw_record.split(@multi_value_delim).map {|pair| pair.split('=',2)}]
        end

        records
      end

      # Called by the initialize method
      def parse_response(response_string)

        if (response_string.include? "ERROR~")
           return parse_errors(response_string)
        end

        pairs = response_string.split(@field_delim)
        pairs.each do |p|
          k,v = p.split(@value_delim)
          if @values.has_key?(k)
            @values[k] = [@values[k]] unless @values[k].is_a?(Array)
            @values[k] << v
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

      def parse_code(response)
        if (response.kind_of? Array)
          response.map do |code_and_text|
            k,v = code_and_text.split(/\.\s/, 2)
            k.to_i
          end
        else
          k, v = response.split(/\.\s/, 2)
          [k.to_i]
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
