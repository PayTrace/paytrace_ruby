$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# see: http://help.paytrace.com/api-processing-a-check-sale

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# setting this to false keeps the framework from throwing an exception and halting the integration test at the first error
PayTrace::API::Gateway.raise_exceptions = false

# process sale transaction -- replace with valid customer ID to see it succeed.
PayTrace::Debug.trace do
  params = {
  check_type: "Sale",
  amount: 15.99,
  # replace this with a valid customer ID
  customer_id: 'MoMouse',
  test_flag: 'Y'  
}

  PayTrace::CheckTransaction::process_sale(params)
end

# process manage check -- this is invalid data, you can replace with a valid check number 
# for the login to see it succeed.
PayTrace::Debug.trace do
  params = {
    check_type: "Hold",
    check_id: 1234
  }

  PayTrace::CheckTransaction::manage_check(params)
end

# process a check refund -- replace this with a valid customer ID and amount to see it succeed
PayTrace::Debug.trace do
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

  sa = PayTrace::Address.new({
    name: "Jane Doe",
    street: "1235 Moon Street",
    street2: "Apartment 2C",
    city: "Shortline",
    state: "WA",
    country: "US",
    postal_code: "98134",
    address_type: :shipping
  })

  params = {
    check_type: "Refund",
    amount: 15.99,
    customer_id: "MMouse",
    billing_address: ba,
    shipping_address: sa,
    email: "tom@paytrace.com",
    invoice: "abc1234",
    description: "accidental billing",
    tax: 2.99,
    customer_reference_id: '1234AB',
    discretionary_data: {
      hair_color: :red
    }
  }

  PayTrace::CheckTransaction::process_refund(params)
end