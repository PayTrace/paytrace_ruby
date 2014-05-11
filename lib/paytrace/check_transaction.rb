module PayTrace
  # Provides a number of helper methods to process check transactions
  class CheckTransaction
    # :nodoc:
    PROCESS_SALE_METHOD = "ProcessCheck"
    MANAGE_CHECK_METHOD = "ManageCheck"

    # parameters used by several methods
    COMMON_PARAMETERS = [
      :check_type, 
      :amount, :customer_id, :account_number, :routing_number,
      :email, :invoice, :description, :tax_amount, :customer_reference_id, :billing_address, :shipping_address, :discretionary_data,
      :test_flag
    ]

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

    SALE_OPTIONAL_PARAMETERS = BILLING_AND_SHIPPING_ADDRESS_FIELDS + [
      :email,
      :invoice,
      :description,
      :tax_amount,
      :customer_reference_id,
      :discretionary_data
    ]
    # :doc:

    # See http://help.paytrace.com/api-processing-a-check-sale
    #
    # Process a transaction as a sale by checking account number and routing number.
    # 
    # Required parameters:
    #
    # * *:check_type* -- the check transaction type; typically "Sale"
    # * *:amount* -- the amount of the check
    # * *:account_anumber* -- the checking account number
    # * *:routing_number* -- the checking account routing number
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
    # * *:email* -- the customer email for this transaction
    # * *:invoice* -- an internal invoice number (customer ID token or referenced transaction sale)
    # * *:description* -- a description of the sale (customer ID token or referenced transaction sale)
    # * *:tax_amount* -- the amount of tax on the sale (customer ID token or referenced transaction sale)
    # * *:customer_reference_id* -- a customer reference ID (customer ID token or referenced transaction sale)
    # * *:discretionary_data* -- a hash of optional discretionary data to attach to this transaction
    def self.sale(params = {})
      PayTrace::API::Gateway.send_request(PROCESS_SALE_METHOD, params, [:check_type, :amount, :routing_number, :account_number], SALE_OPTIONAL_PARAMETERS)
    end

    # See http://help.paytrace.com/api-processing-a-check-sale
    #
    # Process a transaction as a sale by checking account number and routing number.
    # 
    # Required parameters:
    #
    # * *:check_type* -- the check transaction type; typically "Sale"
    # * *:amount* -- the amount of the check
    # * *:customer_id -- the customer ID to reference for this sale
    # 
    # Optional parameters are the same as for sale
    def self.customer_id_sale(params = {})
      PayTrace::API::Gateway.send_request(PROCESS_SALE_METHOD, params, [:check_type, :amount, :customer_id], SALE_OPTIONAL_PARAMETERS)
    end

    # Process a transaction as a hold. Parameters are passed by symbol name in a hash. 
    # _Note:_ the parameters for this method are identical to sale; this is simply
    # a convenience method. The :check_type is automatically set to "Hold"
    def self.hold(params = {})
      params = params.dup
      params[:check_type] = "Hold"

      PayTrace::API::Gateway.send_request(PROCESS_SALE_METHOD, params, [], COMMON_PARAMETERS)
    end



    # Process a transaction as a refund. Parameters are passed by symbol name in a hash. 
    # _Note:_ the parameters for this method are identical to sale; this is simply
    # a convenience method. The :check_type is automatically set to "Refund"
    def self.refund(params = {})
      params = params.dup
      params[:check_type] = "Refund"

      PayTrace::API::Gateway.send_request(PROCESS_SALE_METHOD, params, [:check_type, :amount, :routing_number, :account_number])
    end

    # Process a transaction as a refund. Parameters are passed by symbol name in a hash. 
    # _Note:_ the parameters for this method are identical to sale; this is simply
    # a convenience method. The :check_type is automatically set to "Refund"
    def self.refund_by_customer_id(params = {})
      params = params.dup
      params[:check_type] = "Refund"

      PayTrace::API::Gateway.send_request(PROCESS_SALE_METHOD, params, [:check_type, :amount, :customer_id])
    end

    # Process a transaction as a refund. Parameters are passed by symbol name in a hash. 
    # _Note:_ the parameters for this method are identical to sale; this is simply
    # a convenience method. The :check_type is automatically set to "Refund"
    def self.refund_existing_check_id(params = {})
      params = params.dup
      params[:check_type] = "Refund"

      PayTrace::API::Gateway.send_request(PROCESS_SALE_METHOD, params, [:check_type, :check_id])
    end

    # Manage an existing check, setting a new check type if necessary. Params are passed by symbol
    # name in a hash. They are:
    # * *:check_type* -- the (new) type of this check (e.g. "Sale", "Hold", "Refund", etc.)
    # * *:check_id* -- the id of the check to manage
    def self.manage_check(params = {})
      PayTrace::API::Gateway.send_request(MANAGE_CHECK_METHOD, params, [:check_type, :check_id])
    end
  end
end