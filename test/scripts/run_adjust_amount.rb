# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

PayTrace::Debug.trace do
  params = {
    # this must be a valid transaction ID for the credentials supplied
    transaction_id: 938,
    amount: 1.01
  }
  PayTrace::Transaction::adjust_amount(params)
end