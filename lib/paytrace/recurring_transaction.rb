require 'paytrace'

module PayTrace
  # Manages recurring transactions
  class RecurringTransaction
    # :nodoc:
    CREATE_METHOD = "CreateRecur"
    DELETE_METHOD = "DeleteRecur"
    UPDATE_METHOD = "UpdateRecur"
    EXPORT_APPROVED_METHOD = "ExportCustomerRecur"
    EXPORT_SCHEDULED_METHOD = "ExportRecur"

    RECURRING_TRANSACTION_PARAMS = [
      :recur_id,
      :customer_id,
      :recur_frequency,
      :recur_start,
      :recur_next,
      :recur_count,
      :amount,
      :transaction_type,
      :description,
      :recur_receipt,
      :recur_type
    ]

    # :doc:

    # See http://help.paytrace.com/api-exporting-recurring-transactions
    # Exports recurring transactions by recurrence ID or customer ID. Params:
    # * *:recur_id* -- a recurrence ID to export
    # * *:customer_id* -- a customer ID to export
    # _Note:_ only supply a recurrence ID _or_ a customer ID, not both.
    def self.export_scheduled(params = {})
      response =  PayTrace::API::Gateway.send_request(EXPORT_SCHEDULED_METHOD, params, [], RECURRING_TRANSACTION_PARAMS)
      response.parse_records('RECURRINGPAYMENT')
    end

    # See http://help.paytrace.com/api-exporting-a-recurring-transaction
    # Exports the single most recent recurring transaction for a given customer ID, Params: 
    # * *:customer_id* -- the customer ID to be exported for
    def self.export_approved(params = {})
      PayTrace::API::Gateway.send_request(EXPORT_APPROVED_METHOD, params, [], RECURRING_TRANSACTION_PARAMS)
    end

    # See http://help.paytrace.com/api-create-recurring-transaction
    # Creates a recurring transaction. Params:
    # * *:customer_id* -- the customer ID for which the recurrence should be created
    # * *:recur_frequency* -- the frequency of the recurrence; this must be 1 for annually, 8 for semi-annually, A for trimesterly, 2 for quarterly, 9 for bi-monthly, , 3 for monthly, 4 for bi-weekly, 7 for 1st and 15th, 5 for weekly, or 6 for daily
    # * *:recur_start* -- date of the first recurrence
    # * *:recur_count* -- the total number of times the recurring transaction should be processed. Use 999 if the recurring transaction should be processed indefinitely
    # * *:amount* -- the amount of the recurrence
    # * *:transaction_type* -- the transaction type of the recurrence; typically "Sale"
    # * *:description* -- an optional description of the recurrence
    # * *:recur_receipt* -- "Y" to send a receipt to the customer at each recurrence; default is "N"
    # * *:recur_type* -- default value is "C" which represents credit card number. Alternative is "A" which represents an ACH/check transaction
    def self.create(params = {})
      PayTrace::API::Gateway.send_request(CREATE_METHOD, params, [], RECURRING_TRANSACTION_PARAMS)
    end

    # See http://help.paytrace.com/api-deleting-a-recurring-transaction
    # Deletes recurring transactions by recurrence ID or customer ID. Params:
    # * *:recur_id* -- a recurrence ID to export
    # * *:customer_id* -- a customer ID to export
    # _Note:_ only supply a recurrence ID _or_ a customer ID, not both.
    def self.delete(params = {})
      fields = params.has_key?(:recur_id) ? [:recur_id] : [:customer_id]
      response =  PayTrace::API::Gateway.send_request(DELETE_METHOD, params, [], fields)
    end

    # See http://help.paytrace.com/api-update-recurring-transaction
    # Updates parameters of an existing recurrence. Params:
    # * *:recur_id* -- a recurrence ID to update
    # * *:customer_id* -- the customer ID for which the recurrence should be created
    # * *:recur_frequency* -- the frequency of the recurrence; this must be 1 for annually, 8 for semi-annually, A for trimesterly, 2 for quarterly, 9 for bi-monthly, 3 for monthly, 4 for bi-weekly, 7 for 1st and 15th, 5 for weekly, or 6 for daily
    # * *:recur_next* -- the date of the next recurrence
    # * *:recur_count* -- the total number of times the recurring transaction should be processed. Use 999 if the recurring transaction should be processed indefinitely
    # * *:amount* -- the amount of the recurrence
    # * *:transaction_type* -- the transaction type of the recurrence; typically "Sale"
    # * *:description* -- an optional description of the recurrence
    # * *:recur_receipt* -- "Y" to send a receipt to the customer at each recurrence; default is "N"
    # * *:recur_type* -- default value is "C" which represents credit card number. Alternative is "A" which represents an ACH/check transaction; _note:_ only use for check/ACH recurrences
    def self.update(params = {})
      PayTrace::API::Gateway.send_request(UPDATE_METHOD, params, [], RECURRING_TRANSACTION_PARAMS)
    end
  end
end