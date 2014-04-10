# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

PayTrace::Debug.configure_test

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
params = {
  customer_id: "john_doe",
  credit_card: cc,
  billing_address: ba,
  email: "support@paytrace.com",
  phone: "206-555-1212",
  fax: "206-555-1313",
  password: "foxtrot123",
  account_number: 123456789,
  routing_number: 325081403,
  discretionary_data: { hair_color: "blue" }
}
PayTrace::Debug.trace { c = PayTrace::Customer.from_cc_info(params) }