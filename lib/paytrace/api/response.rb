module PayTrace
  module API
    class Response
      attr_reader :values

      def initialize(response_string)
        @field_delim = "|"
        @value_delim = "~"
        @values = {}
        
        pairs = response_string.split(@field_delim)
        pairs.each do |p|
          k,v = p.split(@value_delim)
          @values[k] = v
        end
      end

      def response_code
        @values["RESPONSE"]
      end
    end
  end
end
