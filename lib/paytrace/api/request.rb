module PayTrace
  module API
    class Request
      attr_reader :params, :field_delim, :value_delim

      def initialize()
        @field_delim = "|"
        @value_delim = "~"

        @params= {
          user_name: PayTrace.configuration.user_name,
          password: PayTrace.configuration.password,
          terms: "Y"
        }
      end

      def to_parms_string()
        @params.map do |k,v|
          "#{PayTrace::API.fields.fetch(k)}#{@value_delim}#{v}"
        end.join(@field_delim) << "|"
      end
    end
  end
end
