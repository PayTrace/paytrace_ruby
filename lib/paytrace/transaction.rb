require 'paytrace/api/request'
require 'paytrace/api/gateway'
require 'paytrace/address'
require 'base64'

module PayTrace
  # Manages transaction-related functionality
  class Transaction
    # :nodoc:
    attr_reader :amount, :credit_card, :type, :customer, :billing_address, :shipping_address,:optional_fields
    attr_accessor :response, :discretionary_data

    TRANSACTION_METHOD = "PROCESSTRANX"
    EXPORT_TRANSACTIONS_METHOD = "ExportTranx"
    EXPORT_TRANSACTIONS_RESPONSE = "TRANSACTIONRECORD"
    ATTACH_SIGNATURE_METHOD = "AttachSignature"
    CALCULATE_SHIPPING_COST = "CalculateShipping"
    CALCULATE_SHIPPING_COST_RESPONSE = "SHIPPINGRECORD"
    LEVEL_3_VISA_METHOD = "Level3Visa"
    LEVEL_3_MC_METHOD = "Level3MCRD"
    SETTLE_TRANSACTION_METHOD = "SettleTranx"
    ADJUST_AMOUNT_METHOD = "AdjustAmount"

    # :doc:

    # See http://help.paytrace.com/api-sale
    # Creates a sale transaction. Params (in hash format):
    # * *:amount* -- the amount of the transaction
    # Depending upon the type of sale, the following additional parameters may be present:
    # * *:credit_card* -- a PayTrace::CreditCard object (key entered sale)
    # * *:customer* -- a PayTrace::Customer object (for additional customer data; customer ID token or referenced transaction sale). _Note:_ for discretionary data, the best way to include it is by adding it to the PayTrace::Customer object.
    # * *:optional* -- optional fields hash, kept inside the parameters
    # _Note:_ the following parameters are kept in the optional fields hash
    # * *:swipe* -- credit card swipe data (card swiped sales)
    # * *:customer_id* -- a PayTrace customer ID (customer ID token sale)
    # * *:transaction_id* -- a transaction ID (referenced transaction sale)
    # * *:csc* -- credit card security code (customer ID token or referenced transaction sale)
    # * *:invoice* -- an internal invoice number (customer ID token or referenced transaction sale)
    # * *:description* -- a description of the sale (customer ID token or referenced transaction sale)
    # * *:tax_amount* -- the amount of tax on the sale (customer ID token or referenced transaction sale)
    # * *:customer_reference_id* -- a customer reference ID (customer ID token or referenced transaction sale)
    # * *:return_clr* -- if set to "Y", card level results will be returned w/ the response. Card level results include whether or not the card is a consumer, purchasing, check, rewards, etc. account. Card level results are only returned with requests to process sales or authorizations through accounts on the TSYS/Vital, Heartland, Global, Paymentech, and Trident networks.(customer ID token sale)
    # * *:custom_dba* -- optional value that is sent to the cardholder’s issuer and overrides the business name stored in PayTrace. Custom DBA values are only used with requests to process sales or authorizations through accounts on the TSYS/Vital, Heartland, and Trident networks (customer ID token sale)
    # * *:enable_partial_authentication* -- flag that must be set to ‘Y’ in order to support partial authorization and balance amounts in transaction responses (customer ID token sale)
    def self.sale(args)
      create_transaction(args,TransactionTypes::SALE)
    end

    # See http://help.paytrace.com/api-authorizations
    # Performs an authorization transaction. Params (in hash format):
    # * *:amount* -- the amount of the transaction
    # Depending upon the type of authorization, the following additional parameters may be present:
    # * *:credit_card* -- a PayTrace::CreditCard object (standard authorization)
    # * *:customer* -- a PayTrace::Customer object (for additional customer data; customer ID token or referenced transaction sale). _Note:_ for discretionary data, the best way to include it is by adding it to the PayTrace::Customer object.
    # * *:optional* -- optional fields hash, kept inside the parameters
    # _Note:_ the following parameters are kept in the optional fields hash
    # * *:customer_id* -- a PayTrace customer ID (customer ID token auth)
    # * *:transaction_id* -- a transaction ID (referenced transaction sale)
    # * *:csc* -- credit card security code (customer ID token or referenced transaction auth)
    # * *:invoice* -- an internal invoice number (customer ID token or referenced transaction auth)
    # * *:description* -- a description of the auth (customer ID token or referenced transaction auth)
    # * *:tax_amount* -- the amount of tax on the auth (customer ID token or referenced transaction auth)
    # * *:customer_reference_id* -- a customer reference ID (customer ID token or referenced transaction auth)
    # * *:return_clr* -- if set to "Y", card level results will be returned w/ the response. Card level results include whether or not the card is a consumer, purchasing, check, rewards, etc. account. Card level results are only returned with requests to process auths or authorizations through accounts on the TSYS/Vital, Heartland, Global, Paymentech, and Trident networks.(customer ID token auth)
    # * *:custom_dba* -- optional value that is sent to the cardholder’s issuer and overrides the business name stored in PayTrace. Custom DBA values are only used with requests to process auths or authorizations through accounts on the TSYS/Vital, Heartland, and Trident networks (customer ID token auth)
    # * *:enable_partial_authentication* -- flag that must be set to ‘Y’ in order to support partial authorization and balance amounts in transaction responses (customer ID token auth)
    def self.authorization(args)
      create_transaction(args,TransactionTypes::Authorization)
    end

    # See http://help.paytrace.com/api-refunds
    # Note that the parameters and transaction types are the same as for self.sale
    def self.refund(args)
      create_transaction(args,TransactionTypes::Refund)
    end

    # See http://help.paytrace.com/api-void
    # Performs a void request. Parameters are:
    # * *transaction_id* -- (_Note:_ this is _not_ in a hash!) the transaction ID to void
    def self.void(transaction_id)
      params = {transaction_id: transaction_id}
      t = Transaction.new({type: TransactionTypes::Void,
                          optional:params})
      t.response = t.send_request
      t
    end

    # See http://help.paytrace.com/api-forced-sale
    # Performs a forced approval sale. Params are:
    # *approval_code* -- (_Note:_ this is _not_ in a hash!) the approval code obtained external to the PayTrace system
    # *args* -- the argument hash, see the arguments for self.sale
    def self.forced_sale(approval_code,args)
      args[:approval_code] = approval_code
      create_transaction(args,TransactionTypes::ForcedSale)
    end

    # See http://help.paytrace.com/api-capture
    # Capturing a transaction updates an approved authorization to a pending settlement status that will initiate a transfer of funds. Processing a capture through the PayTrace API may only be accomplished by providing the transaction ID of the unsettled transaction that should be settled. Params are:
    # * *transaction_id* -- the transaction ID to be captured
    def self.capture(transaction_id)
      t = Transaction.new({transaction_id: transaction_id, type: TransactionTypes::Capture,
                          optional:params})
      t.response = t.send_request
      t
    end

    # See http://help.paytrace.com/api-cash-advance
    # Processing a Cash Advance transaction is similar to processing a Sale, however Cash Advances are special transactions that result in cash disbursements to the card holder. Consequently, additional information is required to process Cash Advances. Cash Advances should always be swiped unless your card reader is not able to reader the card’s magnetic stripe. Additionally, your PayTrace account must be specially configured to process this type of transaction. Params are:
    # * *:amount* -- the amount of the cash advance
    # Depending upon the type of cash advance, the following additional parameters may be present:
    # * *:credit_card* -- a PayTrace::CreditCard object (key entered cash advances)
    # * *:optional* -- optional fields hash, kept inside the parameters
    # _Note:_ the following parameters are kept in the optional fields hash
    # * *:swipe* -- swipe data provided with the cash advance (swiped cash advances)
    # * *:cash_advance* -- (swiped cash advances) When set to "Y", this attribute causes a Sale transaction to be processed as a cash advance where cash is given to the customer as opposed to a product or service. Please note that Cash Advances may only be processed on accounts that are set up on the TSYS/Vital network and are configured to process Cash Advances. Also, only swiped/card present Sales may include the CashAdvance parameter
    # * *:id_number* -- the card holder’s drivers license number or other form of photo ID
    # * *:id_expiration* -- the expiration date of the card holder’s photo ID. MM/DD/YYYY
    # * *:cc_last_4* -- the last 4 digits of the card number as it appears on the face of the card
    # * *:billing_address* -- a billing address provided with the cash advance
    # * *:shipping_address* -- a shipping address provided with the cash advance (key entered cash advances)
    # * *:csc* -- credit card security code (key entered cash advances)
    # * *:invoice* -- an internal invoice number (key entered cash advances)
    # * *:description* -- a description of the auth (key entered cash advances)
    # * *:tax_amount* -- the amount of tax on the auth (key entered cash advances)
    # * *:customer_reference_id* -- a customer reference ID (key entered cash advances)
    def self.cash_advance(args)
      args[:cash_advance] = "Y"

      create_transaction(args,TransactionTypes::SALE)
    end

    # See http://help.paytrace.com/api-store-and-forward
    # Processing a store & forward through the PayTrace API will request that the transaction is stored for future authorization for specified amount. Please note that the authorization of the store & forward may be scheduled by provided a StrFwdDate value or manually via the Virtual Terminal. *Note that swiped account numbers and CSC values are not stored. Only the card number and expiration dates are stored from the swipe.*
    # All versions of store and forward may include the following parameters:
    # * *:amount* -- the amount of the store and forward
    # * *:optional* -- optional fields hash, kept inside the parameters
    # The swiped card version takes the following parameters:
    # * *:swipe* -- swipe data provided with the store and forward (in optional parameters hash)
    # The key entered version takes the following parameters:
    # * *:credit_card* -- additional credit card data
    # The customer ID (token) version takes the following parameters:
    # * *:customer_id* -- the customer ID (in optional parameters hash)
    # * *:customer* -- a PayTrace::Customer object for additional customer details
    # * *:csc* -- credit card security code (in optional parameters hash)
    # * *:invoice* -- an internal invoice number (in optional parameters hash)
    # * *:description* -- a description of the auth (in optional parameters hash)
    # * *:tax_amount* -- the amount of tax on the auth (in optional parameters hash)
    # * *:customer_reference_id* -- a customer reference ID (in optional parameters hash)
    # * *:return_clr* -- if set to "Y", card level results will be returned w/ the response. Card level results include whether or not the card is a consumer, purchasing, check, rewards, etc. account. Card level results are only returned with requests to process auths or authorizations through accounts on the TSYS/Vital, Heartland, Global, Paymentech, and Trident networks.(in optional parameters hash)
    # * *:custom_dba* -- optional value that is sent to the cardholder’s issuer and overrides the business name stored in PayTrace. Custom DBA values are only used with requests to process auths or authorizations through accounts on the TSYS/Vital, Heartland, and Trident networks (in optional parameters hash)
    # * *:enable_partial_authentication* -- flag that must be set to ‘Y’ in order to support partial authorization and balance amounts in transaction responses (in optional parameters hash)
    # * *:store_forward_date* -- optional future date when the transaction should be authorized and settled. Only applicable if the TranxType is STR/FWD (in optional parameters hash)
    def self.store_forward(amount,credit_card,args={})
      args[:amount] = amount
      args[:credit_card] = credit_card
      create_transaction(args,TransactionTypes::StoreForward)
    end

    # :nodoc:
    def self.create_transaction(args,type)
      amount = args.delete(:amount)  if args[:amount]
      cc = CreditCard.new(args.delete(:credit_card)) if args[:credit_card]
      customer = args.delete(:customer) if args[:customer]

      t = Transaction.new({ 
        amount: amount,
        credit_card: cc,
        customer: customer,
        type: type,
        optional:args})      
      t.send_request

      t
    end

    # Not meant to be called directly; use static helper methods instead
    def initialize(params = {})
      @amount = params[:amount]
      @credit_card = params[:credit_card]
      @type = params[:type]
      @customer = params[:customer]
      @discretionary_data = params[:discretionary_data] || {}
      include_optional(params[:optional]) if params[:optional]
    end

    # Internal helper method
    def set_request(request)
      add_credit_card(request, credit_card) if credit_card
      if customer.is_a?(Fixnum)
        request.set_param(:customer_id, customer)
      end
      add_transaction_info(request)
      add_addresses(request)
      add_optional_fields(request) if optional_fields
      if @discretionary_data.any?
        request.set_discretionary(@discretionary_data)
      end
    end
    # :doc:

    # See http://help.paytrace.com/api-export-transaction-information
    # Exports transaction information.
    # Parameters hash:
    # * *:transaction_id* -- a specific transaction ID to export, _or_
    # * *:start_date* -- a start date for a range of transactions to export
    # * *:end_date* -- an end date for a range of transactions to export
    # * *:transaction_type* -- the type of transaction to export (optional)
    # * *:customer_id* -- a specific customer ID to export transactions for (optional)
    # * *:transaction_user* -- the user who created the transaction (optional)
    # * *:return_bin* -- if set to 'Y', card numbers from ExportTranx and ExportCustomers requests will include the first 6 and last 4 digits of the card number (optional)
    # * *:search_text* -- text that will be searched to narrow down transaction and check results for ExportTranx and ExportCheck requests (optional)
    def self.export(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, EXPORT_TRANSACTIONS_METHOD)
      request.set_params([
        :transaction_id,
        :start_date, 
        :end_date, 
        :transaction_type, 
        :customer_id, 
        :transaction_user, 
        :return_bin,
        :search_text], params)

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)

      unless response.has_errors?
        response.parse_records(EXPORT_TRANSACTIONS_RESPONSE)
      end
    end

    # See http://help.paytrace.com/api-signature-capture-image
    # Attach Signature Request -- allows attaching a signature image to a transactions
    # Parameters hash includes:
    # * *:transaction_id* -- the transaction ID to attach a signature image
    # * *:image_data* -- the Base64 encoded image data
    # * *:image_type* -- the type of image attached (e.g. "PNG", "JPG", etc.)
    # * *:image_file* -- the filename of an image file to load and Base64 encode
    # _Note:_ only include the :image_data _or_ :image_file parameters. Also note that (due to technical limitations) if you supply the :image_file parameter, you must still supply the :image_type parameter.
    def self.attach_signature(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, ATTACH_SIGNATURE_METHOD)
      request.set_params([:transaction_id, 
        :image_data, 
        :image_type], params)
      if params.has_key?(:image_file)
        File.open(params[:image_file], 'rb') do |file|
          request.set_param(:image_data, Base64.encode64(file.read))
        end
      end

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end

    # See http://help.paytrace.com/api-calculate-shipping-rates
    # Calculates the estimaged shipping cost to send a package of a given weight from a source zip to a destination.
    # Returns an array of potential shippers, such as USPS, Fedex, etc., and the estimated cost to ship the package
    # Params hash includes:
    # * *:source_zip* -- the zip code the package will be shipped from
    # * *:source_state* -- the state the package will be shipped from
    # * *:shipping_postal_code* -- the postal (zip) code the package will be shipped to
    # * *:shipping_state* -- the state the package will be shipped to
    # * *:shipping_weight* -- the weight of the package
    # * *:shippers* -- string of shipping service providers you would like shipping quotes from. String may contain USPS, FEDEX, or UPS, separated by commas, in any order or combination
    def self.calculate_shipping(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, CALCULATE_SHIPPING_COST)
      request.set_params([
        :source_zip,
        :source_state,
        :shipping_postal_code,
        :shipping_state,
        :shipping_weight,
        :shippers       
      ], params)

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.parse_records(CALCULATE_SHIPPING_COST_RESPONSE)
      end
    end

    # See http://help.paytrace.com/api-adding-level-3-data-to-a-visa-sale
    #
    # Level 3 data is additional information that may be applied to enrich a transaction’s reporting value to both the merchant and the customers. Generally, merchant service providers offer reduced or qualified pricing for transactions that are processed with Level 3 data.
    # 
    # Level 3 data may be added to any Visa or MasterCard sale that is approved and pending settlement. Some level 3 data, specifically enhanced data such as Invoice and Customer Reference ID, may overlap with data provided with the base transaction. Enhanced data, when applied, will always overwrite such data that may already be stored with the transaction.
    # 
    # Level 3 data consists of enhanced data and 1 or more line item records. This information is intended to describe the details of the transaction and the products or services rendered. However, defaults may be applied in the event that some data is missing or unknown. So, all required fields must be present, even if their values are empty. Empty values will be overwritten with PayTrace defaults.
    # 
    # Please note that Visa and MasterCard each have their own requirements for level 3 data, so your application should be able to determine if the transaction being updated in a Visa or a MasterCard before formatting and sending the request. All Visa account numbers begin with “4” and contain 16 digits. All MasterCard account numbers begin with “5” and also contain 16 digits.
    #
    # Required parameters (in arguments hash): 
    #
    # * *:transaction_id* -- the transaction ID to which to add this data (required)
    #
    # Optional parameters (in arguments hash): 
    #
    # * *:invoice* -- invoice is the identifier for this transaction in your accounting or inventory management system
    # * *:customer_reference_id* -- customer reference ID is only used for transactions that are identified as corporate or purchasing credit cards. The customer reference ID is an identifier that your customer may ask you to provide in order to reference the transaction to their credit card statement
    # * *:tax_amount* -- portion of the original transaction amount that is tax. Must be a number that reports the tax amount of the transaction. Use -1 if the transaction is tax exempt
    # * *:national_tax* -- portion of the original transaction amount that is national tax. Generally only applicable to orders shipped to countries with a national or value added tax
    # * *:merchant_tax_id* -- merchant’s tax identifier used for tax reporting purposes
    # * *:customer_tax_id* -- customer’s tax identifier used for tax reporting purposes
    # * *:ccode* -- commodity code that generally applies to each product included in the order. Commodity codes are generally assigned by your merchant service provider
    # * *:discount* -- discount value should represent the amount discounted from the original transaction amount 
    # * *:freight* -- freight value should represent the portion of the transaction amount that was generated from shipping costs
    # * *:duty* -- duty should represent any costs associated with shipping through a country’s customs
    # * *:source_zip* -- zip code that the package will be sent from
    # * *:shipping_postal_code* -- zip code where the product is delivered
    # * *:shipping_country* -- country where the product is delivered
    # * *:add_tax* -- any tax generated from freight or other services associated with the transaction
    # * *:add_tax_rate* -- rate at which additional tax was assessed
    # * *:line_items* -- see below
    #
    # The params may include a :line_items key, which should be an array of zero or more line item detail items. Each detail item is itself a parameter hash, containing any or none of the following:
    #
    # * *:ccode_li* -- the complete commodity code unique to the product referenced in this specific line item record. Commodity codes are generally assigned by your merchant service provider
    # * *:product_id* -- your unique identifier for the product
    # * *:description* -- optional text describing the transaction, products, customers, or other attributes of the transaction
    # * *:quantity* -- item count of the product in this order
    # * *:measure* -- unit of measure applied to the product and its quantity. For example, LBS/LITERS, OUNCES, etc.
    # * *:unit_cost* -- product amount per quantity
    # * *:add_tax_li* -- additional tax amount applied to the transaction applicable to this line item record
    # * *:add_tax_rate_li* -- rate at which additional tax was calculated in reference to this specific line item record
    # * *:discount_li* -- discount amount applied to the transaction amount in reference to this line item record
    # * *:amount_li* -- total amount included in the transaction amount generated from this line item record
    def self.add_level_three_visa(params = {})
      line_items = params.delete(:line_items) || []
      request = PayTrace::API::Request.new
      request.set_param(:method, LEVEL_3_VISA_METHOD)
      request.set_params([
        :transaction_id,
        :invoice,
        :customer_reference_id,
        :tax_amount,
        :national_tax,
        :merchant_tax_id,
        :customer_tax_id,
        :ccode,
        :discount,
        :freight,
        :duty,
        :source_zip,
        :shipping_postal_code,
        :shipping_country,
        :add_tax,
        :add_tax_rate
        ], params)
      line_items.each do |li|
        request.set_multivalue(:line_item, li)
      end

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.values
      end
    end

    # See http://help.paytrace.com/api-adding-level-3-data-to-a-mastercard-sale
    #
    # Level 3 data is additional information that may be applied to enrich a transaction’s reporting value to both the merchant and the customers. Generally, merchant service providers offer reduced or qualified pricing for transactions that are processed with Level 3 data.
    # 
    # Level 3 data may be added to any Visa or MasterCard sale that is approved and pending settlement. Some level 3 data, specifically enhanced data such as Invoice and Customer Reference ID, may overlap with data provided with the base transaction. Enhanced data, when applied, will always overwrite such data that may already be stored with the transaction.
    # 
    # Level 3 data consists of enhanced data and 1 or more line item records. This information is intended to describe the details of the transaction and the products or services rendered. However, defaults may be applied in the event that some data is missing or unknown. So, all required fields must be present, even if their values are empty. Empty values will be overwritten with PayTrace defaults.
    # 
    # Please note that Visa and MasterCard each have their own requirements for level 3 data, so your application should be able to determine if the transaction being updated in a Visa or a MasterCard before formatting and sending the request. All Visa account numbers begin with “4” and contain 16 digits. All MasterCard account numbers begin with “5” and also contain 16 digits.
    #
    # Required parameters (in arguments hash): 
    #
    # * *:transaction_id* -- the transaction ID to which to add this data (required)
    #
    # Optional parameters (in arguments hash): 
    #
    # * *:invoice* -- invoice is the identifier for this transaction in your accounting or inventory management system
    # * *:customer_reference_id* -- customer reference ID is only used for transactions that are identified as corporate or purchasing credit cards. The customer reference ID is an identifier that your customer may ask you to provide in order to reference the transaction to their credit card statement
    # * *:tax_amount* -- portion of the original transaction amount that is tax. Must be a number that reports the tax amount of the transaction. Use -1 if the transaction is tax exempt
    # * *:national_tax* -- portion of the original transaction amount that is national tax. Generally only applicable to orders shipped to countries with a national or value added tax
    # * *:ccode* -- commodity code that generally applies to each product included in the order. Commodity codes are generally assigned by your merchant service provider
    # * *:freight* -- freight value should represent the portion of the transaction amount that was generated from shipping costs
    # * *:duty* -- duty should represent any costs associated with shipping through a country’s customs
    # * *:source_zip* -- zip code that the package will be sent from
    # * *:shipping_postal_code* -- zip code where the product is delivered
    # * *:shipping_country* -- country where the product is delivered
    # * *:add_tax* -- any tax generated from freight or other services associated with the transaction
    # * *:additional_tax_included* -- a flag used to indicate where additional tax was included in this transaction. Set to Y if additional tax was included and N if no additional tax was applied
    # * *:line_items* -- see below
    #
    # The params may include a :line_items key, which should be an array of zero or more line item detail items. Each detail item is itself a parameter hash, containing any or none of the following:
    #
    # * *:product_id* -- your unique identifier for the product
    # * *:description* -- optional text describing the transaction, products, customers, or other attributes of the transaction
    # * *:quantity* -- item count of the product in this order
    # * *:measure* -- unit of measure applied to the product and its quantity. For example, LBS/LITERS, OUNCES, etc.
    # * *:merchant_tax_id* -- merchant’s tax identifier used for tax reporting purposes
    # * *:unit_cost* -- product amount per quantity
    # * *:additional_tax_included_li* -- descriptor used to describe additional tax that is applied to the transaction amount in reference to this specific line item
    # * *:add_tax_li* -- additional tax amount applied to the transaction applicable to this line item record
    # * *:add_tax_rate_li* -- rate at which additional tax was calculated in reference to this specific line item record
    # * *:amount_li* -- total amount included in the transaction amount generated from this line item record
    # * *:discount_included* -- flag used to indicate whether discount was applied to the transaction amount in reference to this specific line item record
    # * *:line_item_is_gross* -- flag used to indicate whether the line item amount is net or gross to specify whether the line item amount includes tax. Possible values are Y (includes tax) and N (does not include tax)
    # * *:is_debit_or_credit* -- flag used to determine whether the line item amount was a debit or a credit to the customer. Generally always a debit or a factor that increased the transaction amount. Possible values are D (net is a debit) and C (net is a credit)
    # * *:discount_li* -- discount amount applied to the transaction amount in reference to this line item record
    # * *:discount_rate* -- rate at which discount was applied to the transaction in reference to this specific line item
    def self.add_level_three_mc(params = {})
      line_items = params.delete(:line_items) || []
      request = PayTrace::API::Request.new
      request.set_param(:method, LEVEL_3_MC_METHOD)
      request.set_params([
        :transaction_id,
        :invoice,
        :customer_reference_id,
        :tax_amount,
        :national_tax,
        :freight,
        :duty,
        :source_zip,
        :shipping_postal_code,
        :shipping_country,
        :add_tax,
        :additional_tax_included
        ], params)
      line_items.each do |li|
        request.set_multivalue(:line_item, li)
      end

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)      
      unless response.has_errors?
        response.values
      end
    end

    # See http://help.paytrace.com/api-settling-transactions
    #
    # Transactions processed through merchant accounts that are set up on the TSYS/Vital network or other terminal-based networks may initiate the settlement of batches through the PayTrace API.
    # 
    # No parameters are required.
    def self.settle_transaction(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, SETTLE_TRANSACTION_METHOD)
      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)      
    end

    # See http://help.paytrace.com/api-adjusting-transaction-amounts
    #
    # Transactions processed through merchant accounts that are set up on the TSYS/Vital network or other terminal-based networks may adjust transaction amounts to any amount that is less than or equal to the original transaction amount and greater than zero. A transaction cannot be adjusted to more than 30% above its authorized amount. Amounts may be adjusted for the following transaction conditions:
    #
    # * Approved Sale that is not yet settled
    # * Forced Sale that is not yet settled
    # * Authorization that is approved and not yet settled
    # * Refund that is not yet settled
    #
    # Please note that amounts for cash advance transaction may also not be adjusted.
    #
    # The parameters hash includes the following required parameters:
    #
    # *:transaction_id* -- a unique identifier for each transaction in the PayTrace system. This value is returned in the TRANSACTIONID parameter of an API response and will consequently be included in requests to email receipts, void transactions, add level 3 data, etc
    # *:amount* -- dollar amount of the transaction. Must be a positive number up to two decimal places
    def self.adjust_amount(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, ADJUST_AMOUNT_METHOD)
      request.set_param(:transaction_id, params[:transaction_id])
      request.set_param(:amount, params[:amount])
      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)      
    end

    # :nodoc:
    def add_transaction_info(request)
      request.set_param(:transaction_type, type)
      request.set_param(:method, TRANSACTION_METHOD)
      request.set_param(:amount, amount)
    end

    def add_credit_card(request, cc)
      cc.set_request(request)
    end

    def add_optional_fields(request)
      o = optional_fields
      o.each do |k,v|
        request.set_param(k, v)
      end


    end

    def add_addresses(request)
      shipping_address.set_request(request) if shipping_address
      billing_address.set_request(request) if billing_address
    end

    def include_optional(args)
      s = nil
      b = nil

      b = args.delete(:billing_address)  if args[:billing_address]
      @billing_address = PayTrace::Address.new({address_type: :billing}.merge(b)) if b
      s =  args.delete(:shipping_address) if args[:shipping_address]
      @shipping_address = PayTrace::Address.new({address_type: :shipping}.merge(s)) if s
      if args[:address_shipping_same_as_billing]
        @shipping_address = @billing_address
      end

      if args.any?
        @optional_fields = args
      end
    end

    def send_request
      request = PayTrace::API::Request.new
      self.set_request(request)

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end
  end

  module TransactionTypes
    SALE = "SALE"
    Authorization = "Authorization"
    Refund = "Refund"
    Void = "Void"
    ForcedSale = "Force"
    Capture = "Capture"
    StoreForward ="Str/FWD"
  end

end
