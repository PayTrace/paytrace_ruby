require 'simplecov'

SimpleCov.start do
  add_filter "lib/paytrace/debug.rb"  
end

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/mini_test'
require 'paytrace'
require "paytrace/debug"

def assert_last_request_equals(expected)
  assert_empty(PayTrace::Debug.diff_requests("UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|" <<expected, PayTrace::API::Gateway.last_request))
end

