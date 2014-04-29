# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

PayTrace::Debug.trace do
  e = PayTrace::EmailReceiptRequest.new({email: "support@paytrace.com", check_id: "62" })
  r = e.send_request
end

PayTrace::Debug.trace do
  e = PayTrace::EmailReceiptRequest.new({email: "support@paytrace.com", transaction_id: "1143"})
  r = e.send_request
end