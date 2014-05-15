# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# see: http://help.paytrace.com/api-processing-a-check-sale

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace.configure do |config|
  config.user_name = "demo123"
  config.password = "demo123"
  config.domain = "stage.paytrace.com"
end

# setting this to false keeps the framework from throwing an exception and halting the integration test at the first error
# it is recommended that you NOT include this line in production code; it's better to see errors early rather than silently 
# produce possibly incorrect data.
PayTrace::API::Gateway.raise_exceptions = false

# unfortunately we have to pre-declare this because the PayTrace::Debug.trace block de-scoped the variable, otherwise
# in production code, you would not wrap this in a trace block (it's only for demonstration), so you wouldn't have to
# pre-declare transaction_id
transaction_id = nil

# this block is just for sample code; do not include the call to trace in production code
PayTrace::Debug.trace do
  # note that most of these parameters are optional; you do not need to include every param to make the call
  # see the SDK documentation for a list of optional and required parameters for each function
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

  # here we create a new customer profile, using the credit card number variant
  PayTrace::Customer.from_cc_info(params)
end

# Debug.trace monitors requests and responses and prints some diagnostic info. It's useful for debugging your applications.
PayTrace::Debug.trace do
  params = {
    # a "sandbox" credit card number
    card_number: 4111111111111111,
    amount: 15.99,
    expiration_month: 10,
    expiration_year: 24
  }

  # a keyed sale is as simple as this
  # note that we capture the response object. This is a wrapper around the returned response data; if there are errors, they 
  # will be in the response object (note that is PayTrace::API::Gateway.raise_exceptions is true -- the default -- a
  # PayTrace::Exceptions::ErrorResponse exception will be raised). Additional data is stored in the response object's values
  # attribute
  response = PayTrace::Transaction::keyed_sale(params)

  # pull the data we care about out
  transaction_id = response.values["TRANSACTIONID"]
end

PayTrace::Debug.trace do
  params = {
    # the transaction ID we received above...
    transaction_id: transaction_id
  }

  # and now we refund that same transaction
  response = PayTrace::Transaction::void(params)
end

PayTrace::Debug.trace do
  # we know the customer id, so we can delete the profile.
  PayTrace::Customer.delete('fake_user')
end

# When run from the console (on a macbook), the following is produced:

# macbook:paytrace_ruby tomc$ ruby test/scripts/sample_transaction.rb
# [REQUEST] UN~demo123|PSWD~demo123|TERMS~Y|METHOD~CreateCustomer|CUSTID~fake_user|BNAME~John Doe|CC~4111111111111111|EXPMNTH~10|EXPYR~24|BADDRESS~1234 Fake Lane.|BADDRESS2~Suite 214|BCITY~Shoreline|BSTATE~WA|BZIP~98133|BCOUNTRY~US|SNAME~John Doe|SADDRESS~3456 Business Road|SADDRESS2~Apartment D|SCITY~Seattle|SSTATE~WA|SZIP~98134|SCOUNTY~King|SCOUNTRY~US|EMAIL~support@paytrace.com|PHONE~206-555-1212|FAX~206-555-1213|CUSTPSWD~foobar|DDA~12345678|TR~325081403|hair_color~red|
# [RESPONSE] ERROR: ERROR-171           171. Please provide a unique customer ID.
# [REQUEST] UN~demo123|PSWD~demo123|TERMS~Y|METHOD~PROCESSTRANX|TRANXTYPE~SALE|AMOUNT~15.99|CC~4111111111111111|EXPMNTH~10|EXPYR~24|
# [RESPONSE] RESPONSE            101. Your transaction was successfully approved.
# [RESPONSE] TRANSACTIONID       2660
# [RESPONSE] APPCODE             TAS301
# [RESPONSE] APPMSG              APPROVAL TAS301  - Approved and completed
# [RESPONSE] AVSRESPONSE         0
# [RESPONSE] CSCRESPONSE
# [REQUEST] UN~demo123|PSWD~demo123|TERMS~Y|METHOD~PROCESSTRANX|TRANXTYPE~Void|TRANXID~2660|
# [RESPONSE] RESPONSE            109. Your transaction was successfully voided.
# [RESPONSE] TRANSACTIONID       2660
# [REQUEST] UN~demo123|PSWD~demo123|TERMS~Y|METHOD~DeleteCustomer|CUSTID~fake_user|
# [RESPONSE] RESPONSE            162. The customer profile for fake_user/John Doe was successfully deleted.
# [RESPONSE] CUSTID              fake_user
# [RESPONSE] CUSTOMERID          fake_user
