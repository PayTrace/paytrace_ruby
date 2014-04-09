require "paytrace"

# see: http://help.paytrace.com/api-email-receipt for details

#
# Helper that loops through the response values and dumps them out
#
def dump_transaction
  puts "[REQUEST] #{PayTrace::API::Gateway.last_request}"
  response = PayTrace::API::Gateway.last_response_object
  if(response.has_errors?)
    response.errors.each do |key, value|
      puts "[RESPONSE] ERROR: #{key.ljust(20)}#{value}"
    end
  else
    response.values.each do |key, value|
      puts "[RESPONSE] #{key.ljust(20)}#{value}"
    end
  end
end

def log(msg)
  puts ">>>>>>           #{msg}"
end

def trace(&block)
  begin
    yield
  ensure
    dump_transaction
  end
end

PayTrace.configure do |config|
  config.user_name = "demo123"
  config.password = "demo123"
  config.domain = "stage.paytrace.com"
end

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

PayTrace::API::Gateway.debug = true

begin
  log "Attempting to remove existing customer 'john_doe'..."
  c = PayTrace::Customer.new("john_doe")
  # delete customer "john_doe" if he already exists
  trace { c.delete() }
rescue PayTrace::Exceptions::ErrorResponse
  log "No such cusomter... continuing..."
end

log "Creating customer john_doe..."
begin
  trace do
    ################
    # create "john_doe" profile from credit card information and a billing address. Also include extra information such as email, phone, and fax
    c = PayTrace::Customer.from_cc_info(params)
    log "Customer ID: #{c.id}"
  end
rescue
  if PayTrace::API::Gateway.last_response_object.errors.has_key?("ERROR-171")
    log "Customer already exists..."
  else
    log "Failure; raw request: #{PayTrace::API::Gateway.last_request}"
    raise
  end
end

log "Creating recurrence for john_doe..."
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

trace do
  ################
  # create a recurring payment for "john_doe" of $9.99 every month starting on 4/22/2016, running indefinitely. Send a receipt.
  recur_id = PayTrace::RecurringTransaction.create(params)
  log "Recurrence ID: #{recur_id}"
end

begin
  log "Exporting recurring transaction..."
  trace do
    ################
    # export any scheduled recurring transactions for "john_doe" to a RecurringTransaction object...
    exported = PayTrace::RecurringTransaction.export_scheduled({customer_id: "john_doe"})
    log "Exported transaction:\n#{exported.inspect}"
  end
rescue
  log "Export failed..."
end

log "Deleting recurrences for 'john_doe'..."
################
# delete any scheduled recurring transactions for "john_doe"
trace { PayTrace::RecurringTransaction.delete({customer_id: "john_doe"}) }

log "Deleting customer 'john_doe'..."
################
# delete "john doe"
trace { c.delete() }