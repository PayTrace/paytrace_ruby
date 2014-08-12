module PayTrace
  module API

    class Factory
      def self.create(klass_name, code, text)
        klass = Class.new do
          def initialize(text)
            @text = text
          end
          attr_reader :text
        end

        new_klass = ResponseCode.const_set(klass_name, klass)
        new_klass.new(text)
      end
    end

    class ResponseCode
      @@factory = PayTrace::API::Factory

      def self.set_class_factory(factory)
        @@factory = factory
      end

      def self.define(code,text)
        if CodeDefinitions.has_key? code.to_sym
          klass_name = CodeDefinitions[code.to_sym]
        else
          klass_name = "DefaultResponse"
        end
        
        if (ResponseCode.const_defined? klass_name)
          klass = ResponseCode.const_get(klass_name)
          klass.new(text)
        else
          @@factory.create(klass_name, code, text)
        end
      end

      CodeDefinitions = {
        :'100' => 'PasswordUpdateSuccess'
      }
    end
  end
end
