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

# this should be a valid credit card number (it can be a "sandbox" number, however)
cc = PayTrace::CreditCard.new({
  card_number: "4111111111111111",
  expiration_month: 12,
  expiration_year: 2014
  })
ba = PayTrace::Address.new({
  name: "John Doe",
  street: "1234 Main Street",
  street2: "Apartment 1B",
  city: "Shoreline",
  state: "WA",
  country: "US",
  postal_code: "98133",
  address_type: :billing
  })
extra = {
  email: "support@paytrace.com",
  phone: "206-555-1212",
  fax: "206-555-1313",
  password: "foxtrot123",
  account_number: 123456789,
  routing_number: 12345678,
  discretionary_data: "Discretionary data."
}

PayTrace::API::Gateway.set_debug(true)
c = PayTrace::Customer.from_cc_info("john_doe", cc, ba, nil, extra)

dump_response_values(PayTrace::API::Gateway.last_response)