module PayTrace
  # Provides a number of helper methods to process check transactions
  class CheckTransaction
    PROCESS_SALE_METHOD = "ProcessCheck"
    MANAGE_CHECK_METHOD = "ManageCheck"

    # Process a transaction as a sale. Parameters are passed by symbol name in a hash. 
    # _Note:_ either supply a customer ID *or* an account/routing number. Although passing in
    # both sets of data will not raise an error, the backend API will ignore the account/routing
    # number if the customer ID is supplied
    # 
    # The parameters are:
    # * *:check_type* -- the check transaction type; typically "Sale"
    # * *:amount* -- the amount of the check
    # * *:customer_id* -- the customer ID for the check
    # * *:account_anumber* -- the checking account number
    # * *:routing_number* -- the checking account routing number
    # * *:email* -- the customer's email
    # * *:invoice* -- an invoice number to apply to the sale
    # * *:description* -- a free text description of the sale
    # * *:tax_amount* -- the tax amount for the sale
    # * *:customer_reference_id* -- an optional customer reference number
    # * *:discretionary_data* -- any discretionary data to be applied
    # * *:shipping_address* -- a shipping address object; see PayTrace::Address
    # * *:billing_address* -- a billing address object; see PayTrace::Address
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

    # Process a transaction as a hold. Parameters are passed by symbol name in a hash. 
    # _Note:_ the parameters for this method are identical to process_sale; this is simply
    # a convenience method. The :check_type is automatically set to "Hold"
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

    # Process a transaction as a refund. Parameters are passed by symbol name in a hash. 
    # _Note:_ the parameters for this method are identical to process_sale; this is simply
    # a convenience method. The :check_type is automatically set to "Hold"
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

    # Manage an existing check, setting a new check type if necessary. Params are passed by symbol
    # name in a hash. They are:
    # * *:check_type* -- the (new) type of this check (e.g. "Sale", "Hold", "Refund", etc.)
    # * *:check_id* -- the id of the check to manage
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

    # Helper method called by the framework. Do not call directly.
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