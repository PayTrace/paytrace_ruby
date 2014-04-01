module PayTrace
  class Customer
    attr :id, :customer_id
    CREATE_CUSTOMER = "CreateCustomer"
    UPDATE_CUSTOMER = "UpdateCustomer"
    def initialize(customer_id = nil)
      @customer_id = customer_id
    end

    def update(params = {})
      set_request_data(UPDATE_CUSTOMER, params)
    end

    def self.from_cc_info(params = {})
      customer = Customer.new(params[:customer_id])
      customer.set_request_data(CREATE_CUSTOMER, params)
    end

    def self.from_transaction_id(params = {})
      customer = Customer.new(params[:customer_id])
      customer.set_request_data(CREATE_CUSTOMER, params)
    end

    def set_request_data(method, params)
      request = PayTrace::API::Request.new
      request.set_param(:method, method)
      request.set_param(:customer_id, params[:customer_id])
      request.set_param(:new_customer_id, params[:new_customer_id])
      request.set_param(:transaction_id, params[:transaction_id])

      if params[:billing_address]
        params[:billing_address].name = nil if (method == CREATE_CUSTOMER && params[:transaction_id])
        params[:billing_address].set_request(request)
      end
      params[:shipping_address].set_request(request) if params[:shipping_address]
        

      if params[:credit_card]
        request.set_param(:card_number, params[:credit_card].card_number)
        request.set_param(:expiration_month, params[:credit_card].expiration_month)
        request.set_param(:expiration_year, params[:credit_card].expiration_year)
      end

      request.set_param(:email, params[:email])
      request.set_param(:customer_phone, params[:phone]) 
      request.set_param(:customer_fax, params[:fax]) 
      request.set_param(:customer_password, params[:customer_password])
      request.set_param(:account_number, params[:account_number])
      request.set_param(:routing_number, params[:routing_number])
      request.set_param(:discretionary_data, params[:discretionary_data])

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)
      unless response.has_errors?
        values = response.values
        @id = values["CUSTID"]
        @customer_id = values["CUSTOMERID"]
        self
      end
    end
  end
end

