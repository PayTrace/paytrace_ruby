$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# settle a transaction via a recurrence ID
PayTrace::Debug.trace do
  params = { recur_id: "1143" } # you must replace this with a valid recurrence ID!
  PayTrace::Transaction.settle_transaction(params)
end

# settle a transaction via a customer ID
PayTrace::Debug.trace do
  params = { customer_id: "1143" } # you must replace this with a valid customer ID!
  PayTrace::Transaction.settle_transaction(params)
end