module PayTrace
  module API
    class ResponseCode
      def self.define(code,text)
        klass = Class.new do
          def initialize(text)
	    @text = text
          end
          attr_reader :text
        end

        klass_name = CodeDefinitions[code.to_sym]
        new_klass = self.const_set(klass_name, klass)
        new_klass.new(text)
      end

      CodeDefinitions = {
        :'100' => 'PasswordUpdateSuccess'
      }
    end
  end
end
