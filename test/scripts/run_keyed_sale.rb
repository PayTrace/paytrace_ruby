$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# see: http://help.paytrace.com/api-processing-a-check-sale

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")


transaction_id = nil

# Debug.trace monitors requests and responses and prints some diagnostic info. You can omit this if you don't need it.
PayTrace::Debug.trace do
  params = {
    # a "sandbox" credit card number
    card_number: 4111111111111111,
    amount: 15.99,
    expiration_month: 10,
    expiration_year: 24
  }

  # a keyed sale is as simple as this
  response = PayTrace::Transaction::keyed_sale(params)

  transaction_id = response.values["TRANSACTIONID"]
end

PayTrace::Debug.trace do
  params = {
    transaction_id: transaction_id
  }

  # and now we refund that same transaction
  response = PayTrace::Transaction::void(params)
end