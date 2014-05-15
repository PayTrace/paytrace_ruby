$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# see: http://help.paytrace.com/api-processing-a-check-sale

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# setting this to false keeps the framework from throwing an exception and halting the integration test at the first error
PayTrace::API::Gateway.raise_exceptions = false

transaction_id = nil

PayTrace::Debug.trace do
  params = {
    customer_id: 'fake_user',
    card_number: 4111111111111111,
    expiration_month: 10,
    expiration_year: 24,
    billing_name: 'John Doe',
    billing_address: '1234 Fake Lane.',
    billing_address2: 'Suite 214',
    billing_city: 'Shoreline',
    billing_state: 'WA',
    billing_postal_code: 98133,
    shipping_name: 'John Doe',
    billing_country: 'US',
    shipping_address: '3456 Business Road',
    shipping_address2: 'Apartment D',
    shipping_city: 'Seattle',
    shipping_region: 'King',
    shipping_state: 'WA', 
    shipping_postal_code: 98134,
    shipping_country: 'US',
    email: 'support@paytrace.com',
    customer_phone: '206-555-1212',
    customer_fax: '206-555-1213',
    customer_password: 'foobar',
    account_number: 12345678,
    routing_number: 325081403,
    discretionary_data: {hair_color: 'red'}
  }

  PayTrace::Customer.from_cc_info(params)
end

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

PayTrace::Debug.trace do
  PayTrace::Customer.delete('fake_user')
end
