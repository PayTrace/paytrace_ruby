$:<< "./lib"

require "paytrace"

# see: http://help.paytrace.com/api-email-receipt for details

#
# Helper that loops through the response values and dumps them out
#
def dump_transaction
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

def log(msg)
  puts ">>>>>>           #{msg}"
end

def trace(&block)
  PayTrace::API::Gateway.debug = true

  begin
    yield
  rescue Exception => e
    raise
  else
    dump_transaction
  end
end

PayTrace.configure do |config|
  config.user_name = "demo123"
  config.password = "demo123"
  config.domain = "stage.paytrace.com"
end

PayTrace::API::Gateway.debug = true

trace {
  PayTrace::Transaction.attach_signature({image_file: File.expand_path('smiley_face.png', File.dirname(__FILE__)), image_type: "PNG"})
}