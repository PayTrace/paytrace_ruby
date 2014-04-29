# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# see: http://help.paytrace.com/api-email-receipt for details

PayTrace::Debug.trace {
  PayTrace::Transaction.attach_signature({transaction_id: 1143, image_file: File.expand_path('smiley_face.png', File.dirname(__FILE__)), image_type: "PNG"})
}