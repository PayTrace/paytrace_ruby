require 'paytrace'

module PayTrace
  # Useful helper methods for debugging.
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

    # Formatted output for a text message.
    def self.log(msg)
      puts ">>>>>>           #{msg}"
    end

    # Helper method to dump a request response pair. Usage:
    # Usage: 
    #  PayTrace::Debug.trace do
    #  # code the intiates a request/response pair
    #  end
    # _Note:_ also includes exception handling to ensure responses are dumped even if an exception occurs
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

    # Helper method to configure a default test environment. Accepts *username*, *password*, and *domain* parameters.
    # domain defaults to "stage.paytrace.com" and the username/password default to the credentials for the sandbox account
    def self.configure_test(un = "demo123", pw = "demo123", domain = "stage.paytrace.com")
      PayTrace.configure do |config|
        config.user_name = un
        config.password = pw
        config.domain = domain
      end
    end
  end
end