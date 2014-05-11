module PayTrace
  # Abstracts the idea of a merchant's customer. Also provides numerous helper methods to aid in managing customers.
  class Customer
    # :nodoc:
    attr :id, :customer_id

    CREATE_CUSTOMER = "CreateCustomer"
    UPDATE_CUSTOMER = "UpdateCustomer"
    DELETE_CUSTOMER = "DeleteCustomer"
    EXPORT_CUSTOMERS = "ExportCustomers"
    EXPORT_INACTIVE_CUSTOMERS = "ExportInactiveCustomers"
    EXPORT_CUSTOMERS_RESPONSE = "CUSTOMERRECORD"

    BILLING_AND_SHIPPING_ADDRESS_FIELDS = [
      :billing_name,
      :billing_address,
      :billing_address2,
      :billing_city,
      :billing_state,
      :billing_postal_code,
      :billing_country,
      :shipping_name,
      :shipping_address,
      :shipping_address2,
      :shipping_city,
      :shipping_state,
      :shipping_postal_code,
      :shipping_region,
      :shipping_country
    ]

    CUSTOMER_OPTIONAL_PARAMS = BILLING_AND_SHIPPING_ADDRESS_FIELDS + [
      :email,
      :customer_phone,
      :customer_fax,
      :customer_password,
      :account_number,
      :routing_number,
      :discretionary_data
    ]
    
    # :doc:

    # See http://help.paytrace.com/api-update-customer-profile
    #
    # Updates the customer's information from parameters hash.
    #
    # Required parameters:
    #
    # * *:customer_id* -- the customer ID of the profile to update
    #
    # Updates the customer's information from parameters hash. See the self.from_cc_info and self.from_transaction_id for
    # information on the permitted parameters. Immediately updates the profile.
    def self.update(params = {})
      PayTrace::API::Gateway.send_request(UPDATE_CUSTOMER, params, [:customer_id], CUSTOMER_OPTIONAL_PARAMS + [
        :card_number,
        :expiration_month,
        :expiration_year,
        :new_customer_id
      ])
    end

    # See http://help.paytrace.com/api-exporting-customer-profiles for more information.
    # Exports a customer's (or multiple customers') profile information. Params:
    # * *:customer_id* -- the customer ID to export
    # * *:email* -- the email of the customer to export
    # * *:transaction_user* -- the user name of the PayTrace user who created or processed the customer or transaction you are trying to export
    # * *:return_bin* -- if set to "Y", card numbers from ExportTranx and ExportCustomers requests will include the first 6 and last 4 digits of the card number
    def self.export(params = {})
      response = PayTrace::API::Gateway.send_request(EXPORT_CUSTOMERS, params, [], [:customer_id, :email, :transaction_user, :return_bin])
      response.parse_records(EXPORT_CUSTOMERS_RESPONSE)
    end

    # See http://help.paytrace.com/api-exporting-inactive-customers
    # Exports the profiles of customers who have been inactive for a certain length of time. Params:
    # *:days_inactive* -- the number of days of inactivity to search for
    def self.export_inactive(params = {})
      response = PayTrace::API::Gateway.send_request(EXPORT_INACTIVE_CUSTOMERS, params, [:days_inactive], [])
      response.parse_records(EXPORT_CUSTOMERS_RESPONSE)
    end

    # See http://help.paytrace.com/api-delete-customer-profile
    # Performs the same functionality as Customer.delete, but saves a step by not requiring the user to instantiate a new Customer object first. Params:
    # *customer_id* -- the merchant-assigned customer ID of the profile to delete
    def self.delete(customer_id)
      PayTrace::API::Gateway.send_request(DELETE_CUSTOMER, {customer_id: customer_id}, [:customer_id])
    end

    # See http://help.paytrace.com/api-create-customer-profile
    #
    # Creates a new customer profile from credit card information.
    #
    # Required parameters:
    #
    # * *:customer_id* -- customer ID to use
    # * *:billing_name* -- the billing name for this transaction
    # * *:card_number* -- a credit card number
    # * *:expiration_month* -- the expiration month for the credit card
    # * *:expiration_year* -- the expiration year for the credit card
    #
    # Optional parameters:
    #
    # * *:billing_name* -- the billing name for this transaction
    # * *:billing_address* -- the billing street address for this transaction
    # * *:billing_address2* -- the billing street address second line (e.g., apartment, suite) for this transaction
    # * *:billing_city* -- the billing city for this transaction
    # * *:billing_state* -- the billing state for this transaction
    # * *:billing_postal_code* -- the billing zip code for this transaction
    # * *:billing_country* -- the billing country for this transaction
    # * *:shipping_name* -- the shipping name for this transaction
    # * *:shipping_address* -- the shipping street address for this transaction
    # * *:shipping_address2* -- the shipping street address second line (e.g., apartment, suite) for this transaction
    # * *:shipping_city* -- the shipping city for this transaction
    # * *:shipping_state* -- the shipping state for this transaction
    # * *:shipping_postal_code* -- the shipping zip code for this transaction
    # * *:shipping_region* -- the shipping region (e.g. county) for this transaction
    # * *:shipping_country* -- the shipping country for this transaction
    # *:email* -- the customer's email address
    # *:customer_phone* -- the customer's phone number
    # *:customer_fax* -- the customer's fax number
    # *:customer_password* -- password that customer uses to log into customer profile in shopping cart. Only required if you are using the PayTrace shopping cart. 
    # *:account_number* -- a checking account number to use for the customer
    # *:routing_number* -- a bank routing number to use
    # *:discretionary_data* -- discretionay data (if any) for the customer, expressed as a hash
    def self.from_cc_info(params = {})
      PayTrace::API::Gateway.send_request(CREATE_CUSTOMER, params, [
        :customer_id,
        :billing_name,
        :card_number,
        :expiration_month,
        :expiration_year], CUSTOMER_OPTIONAL_PARAMS)
    end

    # See http://help.paytrace.com/api-create-customer-profile
    #
    # Creates a new customer profile from a previous transaction.
    #
    # Required parameters:
    #
    # * *:customer_id* -- customer ID to use
    # * *:billing_name* -- the billing name for this transaction
    # * *:card_number* -- a credit card number
    # * *:expiration_month* -- the expiration month for the credit card
    # * *:expiration_year* -- the expiration year for the credit card
    #
    # Optional parameters are the same as *:from_cc_info*
    def self.from_transaction_id(params = {})
      PayTrace::API::Gateway.send_request(CREATE_CUSTOMER, params, [:customer_id, :transaction_id], CUSTOMER_OPTIONAL_PARAMS)
    end
  end
end

