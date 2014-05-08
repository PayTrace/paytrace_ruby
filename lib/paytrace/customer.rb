module PayTrace
  # Abstracts the idea of a merchant's customer. Also provides numerous helper methods to aid in managing customers.
  class Customer
    attr :id, :customer_id

    # :nodoc:
    CREATE_CUSTOMER = "CreateCustomer"
    UPDATE_CUSTOMER = "UpdateCustomer"
    DELETE_CUSTOMER = "DeleteCustomer"
    EXPORT_CUSTOMERS = "ExportCustomers"
    EXPORT_INACTIVE_CUSTOMERS = "ExportInactiveCustomers"
    EXPORT_CUSTOMERS_RESPONSE = "CUSTOMERRECORD"

    # :doc:
    # Initializer. Only param is:
    # *customer_id* -- the merchant-generated customer ID, if present
    def initialize(customer_id = nil)
      @customer_id = customer_id
    end

    # See http://help.paytrace.com/api-update-customer-profile
    # Updates the customer's information from parameters hash. See the self.from_cc_info and self.from_transaction_id for
    # information on the permitted parameters. Immediately updates the profile.
    def update(params = {})
      send_request(UPDATE_CUSTOMER, params)
    end

    # See http://help.paytrace.com/api-delete-customer-profile
    # Sends a request to the server to delete a given customer. No parameters; the customer ID is assumed to be set on
    # this object.
    def delete
      request = PayTrace::API::Request.new
      request.set_param(:method, DELETE_CUSTOMER)
      request.set_param(:customer_id, @customer_id)
      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end

    # See http://help.paytrace.com/api-exporting-customer-profiles for more information.
    # Exports a customer's (or multiple customers') profile information. Params:
    # * *:customer_id* -- the customer ID to export
    # * *:email* -- the email of the customer to export
    # * *:transaction_user* -- the user name of the PayTrace user who created or processed the customer or transaction you are trying to export
    # * *:return_bin* -- if set to "Y", card numbers from ExportTranx and ExportCustomers requests will include the first 6 and last 4 digits of the card number
    def self.export(params = {})
      # CUSTID, EMAIL, USER, RETURNBIN
      request = PayTrace::API::Request.new
      request.set_param(:method, EXPORT_CUSTOMERS)
      request.set_param(:customer_id, params[:customer_id])
      request.set_param(:email, params[:email])
      request.set_param(:transaction_user, params[:transaction_user])
      request.set_param(:return_bin, params[:return_bin])
      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request, [EXPORT_CUSTOMERS_RESPONSE])      

      unless response.has_errors?
        response.values[EXPORT_CUSTOMERS_RESPONSE]
      end
    end

    # See http://help.paytrace.com/api-exporting-inactive-customers
    # Exports the profiles of customers who have been inactive for a certain length of time. Params:
    # *:days_inactive* -- the number of days of inactivity to search for
    def self.export_inactive(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, EXPORT_INACTIVE_CUSTOMERS)
      request.set_param(:days_inactive, params[:days_inactive])
      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request, [EXPORT_CUSTOMERS_RESPONSE])

      unless response.has_errors?
        response.values[EXPORT_CUSTOMERS_RESPONSE]
      end
    end

    # See http://help.paytrace.com/api-delete-customer-profile
    # Performs the same functionality as Customer.delete, but saves a step by not requiring the user to instantiate a new Customer object first. Params:
    # *customer_id* -- the merchant-assigned customer ID of the profile to delete
    def self.delete(customer_id)
      Customer.new(customer_id).delete
    end

    # See http://help.paytrace.com/api-create-customer-profile
    # Creates a new customer profile from credit card information. Params:
    # *:customer_id* -- customer ID to use
    # *:billing_address* -- a PayTrace::Address object; at minimum the billing name must be filled out
    # *:credit_card* -- a PayTrace::CreditCard object
    # *:shipping_address* -- a PayTrace::Address object representing the shipping address
    # *:email* -- the customer's email address
    # *:customer_phone* -- the customer's phone number
    # *:customer_fax* -- the customer's fax number
    # *:customer_password* -- password that customer uses to log into customer profile in shopping cart. Only required if you are using the PayTrace shopping cart. 
    # *:account_number* -- a checking account number to use for the customer
    # *:routing_number* -- a bank routing number to use
    # *:discretionary_data* -- discretionay data (if any) for the customer, expressed as a hash
    def self.from_cc_info(params = {})
      customer = Customer.new(params[:customer_id])
      customer.send_request(CREATE_CUSTOMER, params)
    end

    # See http://help.paytrace.com/api-create-customer-profile
    # Creates a new customer profile from credit card information. Params are the same as from_cc_info, with the exception that *:transaction_id* is used to reference a previous sale transaction instead of a credit card.
    def self.from_transaction_id(params = {})
      customer = Customer.new(params[:customer_id])
      customer.send_request(CREATE_CUSTOMER, params)
    end

    # :nodoc:
    # Internal helper method; not meant to be called directly.
    def send_request(method, params)
      request ||= PayTrace::API::Request.new
      request.set_param(:method, method)
      if params[:billing_address]
        params[:billing_address].name = nil if (method == CREATE_CUSTOMER && params[:transaction_id])
      end
      set_request_data(params, request)

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)
      unless response.has_errors?
        values = response.values
        @id = values["CUSTID"]
        @customer_id = values["CUSTOMERID"]
        self
      else
        nil
      end
    end

    # :nodoc:
    # Internal helper method; not meant to be called directly.
    def set_request_data(params, request = nil)
      request ||= PayTrace::API::Request.new
      request.set_params([
        :customer_id,
        :new_customer_id,
        :transaction_id,
        :email,
        [:customer_phone, :phone],
        [:customer_fax, :fax],
        :customer_password,
        :account_number,
        :routing_number
        ], params)

      params[:billing_address].set_request(request) if params[:billing_address]
      params[:shipping_address].set_request(request) if params[:shipping_address]
      params[:credit_card].set_request_data(request) if params[:credit_card]

      request.set_discretionary(params[:discretionary_data])
    end
  end
end

