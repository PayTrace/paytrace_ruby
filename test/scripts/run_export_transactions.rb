# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

PayTrace::API::Gateway.debug = true

params = {
  start_date: "04/01/2014",
  end_date: "05/31/2014",
  # transaction_id: 1143
}

PayTrace::Debug.trace { puts PayTrace::Transaction.export(params) }