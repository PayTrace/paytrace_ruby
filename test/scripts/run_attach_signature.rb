$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

PayTrace::Debug.configure_test

# see: http://help.paytrace.com/api-email-receipt for details

PayTrace::Debug.trace {
  PayTrace::Transaction.attach_signature({image_file: File.expand_path('smiley_face.png', File.dirname(__FILE__)), image_type: "PNG"})
}