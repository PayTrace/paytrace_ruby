# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

PayTrace::Debug.configure_test

# this should dump out a wall of text...
PayTrace::Debug.trace { puts PayTrace::Customer.export() }

# this should dump inactive api-exporting-customer-profiles
PayTrace::Debug.trace { puts PayTrace::Customer.export_inactive({days_inactive: 30}) }