require 'paytrace'

module PayTrace
  # Manages recurring transactions
  class RecurringTransaction
    # :nodoc:
    attr :id, :amount, :customer_id, :next, :total_count, :current_count, :repeat, :description

    CREATE_METHOD = "CreateRecur"
    DELETE_METHOD = "DeleteRecur"
    UPDATE_METHOD = "UpdateRecur"
    EXPORT_APPROVED_METHOD = "ExportCustomerRecur"
    EXPORT_SCHEDULED_METHOD = "ExportRecur"

    def initialize(raw_response)
      response_map = Hash[raw_response.split('+').map {|pair| pair.split('=')}]
      @id = response_map["RECURID"].to_i
      @amount = response_map["AMOUNT"].to_f
      @customer_id = response_map["CUSTID"]
      @next = response_map["NEXT"]
      @total_count = response_map["TOTALCOUNT"].to_i
      @current_count = response_map["CURRENTCOUNT"].to_i
      @repeat = response_map["REPEAT"].to_i
      @description = response_map["DESCRIPTION"]
    end

    def inspect
      "<RecurringTransaction:#{@id},customer id:#{@customer_id},amount: #{@amount},next: #{@next}>"
    end

    # :doc:

    # See http://help.paytrace.com/api-exporting-recurring-transactions
    # Exports recurring transactions by recurrence ID or customer ID. Params:
    # * *:recur_id* -- a recurrence ID to export
    # * *:customer_id* -- a customer ID to export
    # _Note:_ only supply a recurrence ID _or_ a customer ID, not both.
    def self.export_scheduled(params = {})
      parse_response(set_request_data(EXPORT_SCHEDULED_METHOD, params))
    end

    # See http://help.paytrace.com/api-exporting-a-recurring-transaction
    # Exports the single most recent recurring transaction for a given customer ID, Params: 
    # * *:customer_id* -- the customer ID to be exported for
    def self.export_approved(params = {})
      set_request_data(EXPORT_APPROVED_METHOD, params)
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
      parse_response(set_request_data(CREATE_METHOD, params))
    end

    # See http://help.paytrace.com/api-deleting-a-recurring-transaction
    # Deletes recurring transactions by recurrence ID or customer ID. Params:
    # * *:recur_id* -- a recurrence ID to export
    # * *:customer_id* -- a customer ID to export
    # _Note:_ only supply a recurrence ID _or_ a customer ID, not both.
    def self.delete(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, DELETE_METHOD)
      if params[:recur_id]
        request.set_param(:recur_id, params[:recur_id])
      else
        request.set_param(:customer_id, params[:customer_id])
      end

      gateway = PayTrace::API::Gateway.new
      parse_response(gateway.send_request(request))
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
      parse_response(set_request_data(UPDATE_METHOD, params))
    end

    # :nodoc:
    def self.parse_response(response)
      unless response.has_errors?
        values = response.values

        if values.has_key?("RECURRINGPAYMENT")
          new(values["RECURRINGPAYMENT"])
        else
          values["RECURID"]
        end
      end
    end

    def self.set_request_data(method, params)
      request = PayTrace::API::Request.new
      request.set_param(:method, method)

      request.set_param(:recur_id, params[:recur_id])
      request.set_param(:customer_id, params[:customer_id])
      request.set_param(:recur_frequency, params[:recur_frequency])
      request.set_param(:recur_start, params[:recur_start])
      request.set_param(:recur_next, params[:recur_next])
      request.set_param(:recur_count, params[:recur_count])
      request.set_param(:amount, params[:amount])
      request.set_param(:transaction_type, params[:transaction_type])
      request.set_param(:description, params[:description])
      request.set_param(:recur_receipt, params[:recur_receipt])
      request.set_param(:recur_type, params[:recur_type])

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end
    # :doc:
  end
end