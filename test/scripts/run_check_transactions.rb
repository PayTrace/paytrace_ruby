$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# http://help.paytrace.com/api-processing-a-check-sale

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