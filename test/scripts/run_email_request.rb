# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

PayTrace::Debug.configure_test

PayTrace::Debug.trace do
  e = PayTrace::EmailReceiptRequest.new({email: "support@paytrace.com", check_id: "62" })
  r = e.send_request
end

PayTrace::Debug.trace do
  e = PayTrace::EmailReceiptRequest.new({email: "support@paytrace.com", transaction_id: "1143"})
  r = e.send_request
end