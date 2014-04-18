require 'paytrace'

module PayTrace
  module Debug
    #
    # Helper that loops through the response values and dumps them out
    #
    def self.dump_transaction
      puts "[REQUEST] #{PayTrace::API::Gateway.last_request}"
      response = PayTrace::API::Gateway.last_response_object
      if(response.has_errors?)
        response.errors.each do |key, value|
          puts "[RESPONSE] ERROR: #{key.ljust(20)}#{value}"
        end
      else
        response.values.each do |key, value|
          puts "[RESPONSE] #{key.ljust(20)}#{value}"
        end
      end
    end

    def self.log(msg)
      puts ">>>>>>           #{msg}"
    end

    def self.trace(&block)
      PayTrace::API::Gateway.debug = true

      begin
        yield
      rescue Exception => e
        puts "[REQUEST] #{PayTrace::API::Gateway.last_request}"

        raise
      else
        dump_transaction
      end
    end

    def self.configure_test(un = "demo123", pw = "demo123")
      PayTrace.configure do |config|
        config.user_name = un
        config.password = pw
        config.domain = "stage.paytrace.com"
      end
    end
  end
end