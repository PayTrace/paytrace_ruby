require 'paytrace'

module PayTrace
  class RecurringTransaction
    attr :id
    CREATE_METHOD = "CreateRecur"
    DELETE_METHOD = "DeleteRecur"
    UPDATE_METHOD = "UpdateRecur"

    def self.create(params = {})
      set_request_data(CREATE_METHOD, params)
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
      set_request_data(UPDATE_METHOD, params)
    end

    def self.parse_response(response)
      unless response.has_errors?
        values = response.values
        values["RECURID"]
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
      parse_response(gateway.send_request(request))
    end
  end
end