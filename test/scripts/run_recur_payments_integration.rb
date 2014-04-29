# $:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# this should be a valid credit card number (it can be a "sandbox" number, however)
cc = PayTrace::CreditCard.new({
  card_number: "4111111111111111",
  expiration_month: 12,
  expiration_year: 2014
  })
ba = PayTrace::Address.new({
  name: "John Doe",
  street: "1234 Main Street",
  street2: "Apartment 1B",
  city: "Shoreline",
  state: "WA",
  country: "US",
  postal_code: "98133",
  address_type: :billing
  })

params = {
  customer_id: "john_doe",
  credit_card: cc,
  billing_address: ba,
  email: "support@paytrace.com",
  phone: "206-555-1212",
  fax: "206-555-1313",
  password: "foxtrot123",
  account_number: 123456789,
  routing_number: 325081403,
  discretionary_data: {test: "test data"}
}

begin
  PayTrace::Debug.log "Attempting to remove existing customer 'john_doe'..."
  c = PayTrace::Customer.new("john_doe")
  # delete customer "john_doe" if he already exists
  PayTrace::Debug.trace { c.delete() }
rescue PayTrace::Exceptions::ErrorResponse
  PayTrace::Debug.log "No such cusomter... continuing..."
end

PayTrace::Debug.log "Creating customer john_doe..."
begin
  PayTrace::Debug.trace do
    ################
    # create "john_doe" profile from credit card information and a billing address. Also include extra information such as email, phone, and fax
    c = PayTrace::Customer.from_cc_info(params)
    PayTrace::Debug.log "Customer ID: #{c.id}"
  end
rescue
  if PayTrace::API::Gateway.last_response_object.errors.has_key?("ERROR-171")
    PayTrace::Debug.log "Customer already exists..."
  else
    PayTrace::Debug.log "Failure; raw request: #{PayTrace::API::Gateway.last_request}"
    raise
  end
end

PayTrace::Debug.log "Creating recurrence for john_doe..."
params = {
  customer_id: "john_doe",
  recur_frequency: "3",
  recur_start: "4/22/2016",
  recur_count: 999,
  amount: 9.99,
  transaction_type: "sale",
  description: "Recurring transaction",
  recur_receipt: "Y",
  recur_type: "A"
}

PayTrace::Debug.trace do
  ################
  # create a recurring payment for "john_doe" of $9.99 every month starting on 4/22/2016, running indefinitely. Send a receipt.
  recur_id = PayTrace::RecurringTransaction.create(params)
  PayTrace::Debug.log "Recurrence ID: #{recur_id}"
end

PayTrace::Debug.log "Modify recurrence for john_doe..."
PayTrace::Debug.trace do
  recur_id = PayTrace::RecurringTransaction.create(params)
  PayTrace::Debug.log "Recurrence ID: #{recur_id}"
  update_params = {
    recur_id: recur_id,
    description: "Updated recurring payment"
  }
  PayTrace::RecurringTransaction.update(update_params)
end

PayTrace::Debug.log "Delete a recurrence for john_doe..."
PayTrace::Debug.trace do
  recur_id = PayTrace::RecurringTransaction.create(params)
  PayTrace::Debug.log "Recurrence ID: #{recur_id}"
  PayTrace::RecurringTransaction.delete({recur_id: recur_id})
end


begin
  PayTrace::Debug.log "Exporting recurring transaction..."
  PayTrace::Debug.trace do
    ################
    # export any scheduled recurring transactions for "john_doe" to a RecurringTransaction object...
    exported = PayTrace::RecurringTransaction.export_scheduled({customer_id: "john_doe"})
    PayTrace::Debug.log "Exported transaction:\n#{exported.inspect}"
  end
rescue
  PayTrace::Debug.log "Export failed..."
end

PayTrace::Debug.log "Deleting recurrences for 'john_doe'..."
################
# delete any scheduled recurring transactions for "john_doe"
PayTrace::Debug.trace { PayTrace::RecurringTransaction.delete({customer_id: "john_doe"}) }

PayTrace::Debug.log "Deleting customer 'john_doe'..."
################
# delete "john doe"
PayTrace::Debug.trace { c.delete() }
