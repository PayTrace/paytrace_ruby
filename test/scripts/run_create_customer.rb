$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

params = {
  customer_id: "john_doe",
  card_number: "4111111111111111",
  expiration_month: 12,
  expiration_year: 2014,
  billing_name: "John Doe",
  billing_address: "1234 Main Street",
  billing_address2: "Apartment 1B",
  billing_city: "Shoreline",
  billing_state: "WA",
  billing_country: "US",
  billing_postal_code: "98133",
  email: "support@paytrace.com",
  customer_phone: "206-555-1212",
  customer_fax: "206-555-1313",
  customer_password: "foxtrot123",
  account_number: 123456789,
  routing_number: 325081403,
  discretionary_data: { hair_color: "blue" }
}

PayTrace::Debug.trace { PayTrace::Customer.from_cc_info(params) }