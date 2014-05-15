# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace.configure do |config|
  config.user_name = "demo123"
  config.password = "demo123"
  config.domain = "stage.paytrace.com"
end

# 
# Create a customer profile with a known customer ID
#

# we can handle non-fatal error responses by rescuing PayTrace::Exception::ErrorResponse objects
begin
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
    discretionary_data: {hair_color: 'red'} # note, this is level 3 ("discretionary") data appropriate to your account!
  }

  # here we create a new customer profile, using the credit card number variant
  PayTrace::Customer.from_cc_info(params)
rescue PayTrace::Exceptions::ErrorResponse => e
  if e.response.errors.count == 1 && e.response.errors.has_key?('ERROR-171') # duplicate customer ID
    puts "*** Customer ID #{params[:customer_id]} already exists, continuing..."
  else
    raise
  end
else
  puts "*** Successfully created customer ID #{params[:customer_id]}"
end

# 
# Perform a keyed (manually-entered, as opposed to swiped) sale transaction
#

params = {
  # a "sandbox" credit card number
  card_number: 4111111111111111,
  amount: 15.99,
  expiration_month: 10,
  expiration_year: 24
}

response = PayTrace::Transaction::keyed_sale(params)

# pull the data we care about out
transaction_id = response.values["TRANSACTIONID"]

puts "*** Successfully created transaction ID #{transaction_id}"

# 
# Add level 3 data to a known transaction ID
#

# let's add level 3 data to that transaction...
params = {
  transaction_id: transaction_id,
  line_items: [
    {product_id: 'SKU123', quantity: 3, description: 'Widgets'}
  ]
}

PayTrace::Transaction::add_level_three_visa(params)

puts "*** Successfully added level 3 data to transaction_id #{transaction_id}"

# 
# Void a known transaction ID
#

# void it!
params = {
  # the transaction ID we received above...
  transaction_id: transaction_id
}

# and now we refund that same transaction
response = PayTrace::Transaction::void(params)

puts "*** Successfully voided transaction_id #{transaction_id}"

#
# Perform a refund to a known credit card
#

# now, let's do a refund!
params = {
  amount: 15.99,
  card_number: 4111111111111111,
  expiration_month: 10,
  expiration_year: 24
}

# this might fail if you run against the staging server
# But, it demonstrates the minimal information necessary to perform a keyed refund.
PayTrace::Transaction::keyed_refund(params)

puts "*** Successfully refunded $#{params[:amount]} to card number #{params[:card_number]}"

#
# Delete customer profile
#

# we know the customer id, so we can delete the profile.
PayTrace::Customer.delete('fake_user')

puts "*** Successfully deleted customer ID fake_user"