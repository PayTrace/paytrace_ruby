require 'paytrace'

# see: http://help.paytrace.com/api-email-receipt for details

#
# Helper that loops through the response values and dumps them out
#
def dump_response_values(response)
  if(response.has_errors?)
    response.errors.each do |key, value|
      puts "#{key.ljust(20)}#{value}"
    end
  else
    response.values.each do |key, value|
      puts "#{key.ljust(20)}#{value}"
    end
  end
end

PayTrace.configure do |config|
  config.user_name = "demo123"
  config.password = "demo123"
  config.domain = "stage.paytrace.com"
end

e = PayTrace::EmailReceiptRequest.new("support@paytrace.com", "CHECK2345", true)
r = e.send_request

# this is for the check auth version
dump_response_values(r)

e = PayTrace::EmailReceiptRequest.new("support@paytrace.com", "TRANS1234", false)
r = e.send_request

# this is for the transaction version
dump_response_values(r)