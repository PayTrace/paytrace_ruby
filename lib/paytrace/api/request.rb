module PayTrace
  module API
    class Request
      attr_reader :params, :field_delim, :value_delim, :discretionary_data

      def initialize
        @field_delim = "|"
        @value_delim = "~"

        @params= {
          user_name: PayTrace.configuration.user_name,
          password: PayTrace.configuration.password,
          terms: "Y"
        }

        @discretionary_data = {}
      end

      def to_parms_string()
        raw_request = @params.map do |k,v|
          "#{PayTrace::API.fields[k]}#{@value_delim}#{v}"
        end.join(@field_delim) << @field_delim

        if @discretionary_data.any?
          raw_request << @discretionary_data.map do |k,v|
            "#{k}#{@value_delim}#{v}"
          end.join(@field_delim) << @field_delim
        end

        raw_request
      end

      def set_discretionary(k, v = nil)
        if k.is_a?(Hash)
          @discretionary_data = k
        else
          @discretionary_data[k] = v unless v.nil?
        end
      end

      def set_param(k, v)
        raise PayTrace::Exceptions::ValidationError.new("Unknown field '#{k}'") unless PayTrace::API.fields.has_key?(k)

        @params[k] = v unless v.nil?
      end

      def set_params(keys, params)
        keys.each do |key|
          set_param(key, params[key])
        end
      end
    end
  end
end
