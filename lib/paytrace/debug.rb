require 'paytrace'
require 'minitest/autorun'

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

    # split a raw request string into an array of name-value tuples
    def self.split_request_string(raw)
      raw.split('|').map {|kv_pair| kv_pair.split('~')}
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
      rescue PayTrace::Exceptions::ErrorResponse => e
        puts "[REQUEST] #{PayTrace::API::Gateway.last_request}"
        puts "[RESPONSE] #{PayTrace::API::Gateway.last_response}"
        
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

    # helper method to make CodeClimate happy
    def self.split_tuples(raw, case_sensitive = false)
      PayTrace::Debug.split_request_string(raw).map {|tuple| case_sensitive ? tuple : [tuple[0].upcase, tuple[1]]}
    end

    # verify whether two requests match
    def self.diff_requests(expected_raw, actual_raw, case_sensitive = false)
      whats_wrong = []

      expected = PayTrace::Debug.split_tuples(expected_raw, case_sensitive)
      actual = PayTrace::Debug.split_tuples(actual_raw, case_sensitive)

      expected_remaining = []
      actual_extra = actual.dup

      expected.each do |tuple|
        idx = actual_extra.find_index(tuple)
        if idx.nil?
          expected_remaining << tuple
        else
          actual_extra.delete_at(idx)
        end
      end

      expected_remaining.each do |tuple|
        whats_wrong << "Missing expected property #{tuple[0]}~#{tuple[1]}"
      end

      actual_extra.each do |tuple|
        whats_wrong << "Extra unexpected property #{tuple[0]}~#{tuple[1]}"
      end

      whats_wrong
    end
  end
end