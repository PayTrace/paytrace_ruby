require 'paytrace'

module PayTrace
  class RecurringTransaction
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

    def self.export_scheduled(params = {})
      parse_response(set_request_data(EXPORT_SCHEDULED_METHOD, params))
    end

    def self.export_approved(params = {})
      set_request_data(EXPORT_APPROVED_METHOD, params)
    end

    def self.create(params = {})
      parse_response(set_request_data(CREATE_METHOD, params))
    end

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

    def self.update(params = {})
      parse_response(set_request_data(UPDATE_METHOD, params))
    end

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
      request.set_param(:recur_count, params[:recur_count])
      request.set_param(:amount, params[:amount])
      request.set_param(:transaction_type, params[:transaction_type])
      request.set_param(:description, params[:description])
      request.set_param(:recur_receipt, params[:recur_receipt])
      request.set_param(:recur_type, params[:recur_type])

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end
  end
end