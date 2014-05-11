$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# use a low-security user for this test, so we don't mess up the integration users :)
PayTrace::Debug.configure_test("tom_test_user", "password4", "dev2.paytrace.com")

# see: http://help.paytrace.com/api-updating-user-password for details
PayTrace::Debug.trace {
  # change my demo user password...
  # note, if you run this, it won't run again because the password has been changed :)
  PayTrace.configuration.update_password(new_password: 'password5')
}