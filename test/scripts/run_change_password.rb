$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# make sure we don't mess up the integration users :)
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# see: http://help.paytrace.com/api-updating-user-password for details
PayTrace::Debug.trace {
  # cant change demo123 password anyways.
  PayTrace.configuration.update_password(new_password: 'demo123')
}
