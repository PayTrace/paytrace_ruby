$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

#THESE TEST TAKE FOR EVER AND TIMESOUT.  COMMENTING OUT.

# this should dump out a wall of text...
#PayTrace::Debug.trace { puts PayTrace::Customer.export() }

# this should dump inactive api-exporting-customer-profiles
#PayTrace::Debug.trace { puts PayTrace::Customer.export_inactive({days_inactive: 30}) }