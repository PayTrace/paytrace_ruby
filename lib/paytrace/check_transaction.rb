module PayTrace
  class CheckTransaction
    PROCESS_SALE_METHOD = "ProcessCheck"
    MANAGE_CHECK_METHOD = "ManageCheck"

    def self.process_sale(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, PROCESS_SALE_METHOD)
      self.add_common_parameters(params, request)

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.values
      end
    end

    def self.process_hold(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, PROCESS_SALE_METHOD)
      params.delete(:check_type) # make sure we don't duplicate this
      self.add_common_parameters(params, request)
      request.set_param(:check_type, "Hold")

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.values
      end
    end

    def self.process_refund(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, PROCESS_SALE_METHOD)
      params.delete(:check_type) # make sure we don't duplicate this
      self.add_common_parameters(params, request)
      request.set_param(:check_id, params[:check_id])
      request.set_param(:check_type, "Refund")

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.values
      end
    end

    def self.manage_check(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, MANAGE_CHECK_METHOD)
      request.set_params([:check_type, :check_id], params)

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.values
      end
    end

    def self.add_common_parameters(params = {}, request)
      request.set_params([
        :check_type, 
        :amount, :customer_id, :account_number, :routing_number,
        :email, :invoice, :description, :tax_amount, :customer_reference_id, :test_flag
        ], params)

      if params[:discretionary_data] 
        params[:discretionary_data].keys.each do |k|
          request.set_discretionary(k, params[:discretionary_data][k])
        end
      end

      if params.has_key?(:billing_address)
        params[:billing_address].set_request(request)
      end

      if params.has_key?(:shipping_address)
        params[:shipping_address].set_request(request)
      end
    end
  end
end