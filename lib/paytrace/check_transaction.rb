module PayTrace
  class CheckTransaction
    PROCESS_SALE_METHOD = "ProcessCheck"

    def self.process_sale(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, PROCESS_SALE_METHOD)
      request.set_params([
        :check_type, 
        :amount, :customer_id, :account_number, :routing_number,
        :billing_name, :billing_address, :billing_address2, :billing_city, :billing_state, :billing_postal_code, :billing_country,
        :shipping_name, :shipping_address, :shipping_address2, :shipping_city, :shipping_region, :shipping_state, :shipping_postal_code, :shipping_country,
        :email, :invoice, :description, :tax_amount, :customer_reference_id
        ], params)

      if params[:discretionary_data] 
        params[:discretionary_data].keys.each do |k|
          request.set_discretionary(k, params[:discretionary_data][k])
        end
      end
      
      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.values
      end
    end
  end
end