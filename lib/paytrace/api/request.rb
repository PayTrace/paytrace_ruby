module PayTrace
  module API
    # An object representing an API request to be sent using a PayTrace::API::Gateway object
    class Request
      # :nodoc:
      attr_reader :params, :field_delim, :value_delim, :discretionary_data
      # :doc:

      # Initializes a new Request object
      def initialize
        @field_delim = "|"
        @multi_field_delim = "+"
        @value_delim = "~"
        @multi_value_delim = "="

        @params= {
          user_name: [PayTrace.configuration.user_name],
          password: [PayTrace.configuration.password],
          terms: ["Y"]
        }

        @discretionary_data = {}
      end

      # Returns the formatted URL that this request will send
      def to_parms_string()
        raw_request = @params.map do |k,items|
          items.map do |item|
            "#{PayTrace::API.fields[k]}#{@value_delim}#{item}"
          end
        end.join(@field_delim) << @field_delim

        if @discretionary_data.any?
          raw_request << @discretionary_data.map do |k,v|
            "#{k}#{@value_delim}#{v}"
          end.join(@field_delim) << @field_delim
        end

        raw_request
      end

      # Sets discretionary data keys and values
      # * *:key* -- the name of the setting
      # * *:value* -- the value of the setting
      def set_discretionary(key, value = nil)
        if key.is_a?(Hash)
          @discretionary_data = key
        else
          @discretionary_data[key] = value unless value.nil?
        end
      end

      # :nodoc:
      def validate_param(k, v)
        raise PayTrace::Exceptions::ValidationError.new("Unknown field '#{k}'") unless PayTrace::API.fields.has_key?(k)
      end
      # :doc:

      # Sets a single request parameters
      # * *:key* -- the name of the setting
      # * *:value* -- the value of the setting
      def set_param(key, value = nil)
        validate_param(key, value)

        unless value.nil?
          @params[key] ||= []

          @params[key] << value
        end
      end

      # Sets multiple parameters with the same name using the custom delimiter
      # * *:param_name* -- the name of the "top level" setting
      # * *:items* -- a hash of "second level" settings
      def set_multivalue(param_name, items = {})
        result = (items.map do |k,v|
          validate_param(k, v)
          "#{PayTrace::API.fields[k]}#{@multi_value_delim}#{v}"
        end.join(@multi_field_delim))

        set_param(param_name, result)

        result
      end

      # Sets multiple parameters at once
      # * *:keys* -- an array of key names to extract from the params hash
      # * *:params* -- the parameters hash to be extracted from
      def set_params(keys, params)
        keys.each do |key|
          if key.is_a?(Array)
            request_variable = key[0]
            arg_name = key[1]
            set_param(request_variable, params[arg_name])
          else
            set_param(key, params[key])
          end
        end
      end
    end
  end
end
