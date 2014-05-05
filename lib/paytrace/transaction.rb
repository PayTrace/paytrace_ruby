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

    def initialize(params = {})
      @amount = params[:amount]
      @credit_card = params[:credit_card]
      @type = params[:type]
      @customer = params[:customer]
      @discretionary_data = params[:discretionary_data] || {}
      include_optional(params[:optional]) if params[:optional]
    end

    def set_request(request)
      add_credit_card(request, credit_card) if credit_card
      if customer.is_a?(PayTrace::Customer)
        request.set_param(:customer_id, customer.id)
      elsif customer.is_a?(Fixnum)
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


    def self.export(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, EXPORT_TRANSACTIONS_METHOD)
      request.set_param(:transaction_id, params[:transaction_id])
      request.set_param(:start_date, params[:start_date])
      request.set_param(:end_date, params[:end_date])
      request.set_param(:transaction_type, params[:transaction_type])
      request.set_param(:customer_id, params[:customer_id])
      request.set_param(:transaction_user, params[:transaction_user])
      request.set_param(:return_bin, params[:return_bin])
      request.set_param(:search_text, params[:search_test])

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request, [EXPORT_TRANSACTIONS_RESPONSE])

      unless response.has_errors?
        response.values[EXPORT_TRANSACTIONS_RESPONSE]
      end
    end

    def self.attach_signature(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, ATTACH_SIGNATURE_METHOD)
      request.set_param(:transaction_id, params[:transaction_id])
      request.set_param(:image_data, params[:image_data])
      request.set_param(:image_type, params[:image_type])
      if params.has_key?(:image_file)
        File.open(params[:image_file], 'rb') do |file|
          request.set_param(:image_data, Base64.encode64(file.read))
        end
      end

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end

    def self.calculate_shipping(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, CALCULATE_SHIPPING_COST)
      request.set_params(params.keys, params)

      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request, [CALCULATE_SHIPPING_COST_RESPONSE])      
      unless response.has_errors?
        response.values[CALCULATE_SHIPPING_COST_RESPONSE]
      end
    end

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

    def self.settle_transaction(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, SETTLE_TRANSACTION_METHOD)
      request.set_params([:recur_id, :customer_id], params)
      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)      
    end

    def self.adjust_amount(params = {})
      request = PayTrace::API::Request.new
      request.set_param(:method, ADJUST_AMOUNT_METHOD)
      request.set_param(:transaction_id, params[:transaction_id])
      request.set_param(:amount, params[:amount])
      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)      
    end

    def add_transaction_info(request)
      request.set_param(:transaction_type, type)
      request.set_param(:method, TRANSACTION_METHOD)
      request.set_param(:amount, amount)
    end

    def add_credit_card(request, cc)
      request.set_param(:card_number, cc.card_number) if cc.card_number
      request.set_param(:expiration_month, cc.expiration_month) if cc.expiration_month
      request.set_param(:expiration_year, cc.expiration_year) if cc.expiration_year
      request.set_param(:swipe, cc.swipe) if cc.swipe
      request.set_param(:csc, cc.csc) if cc.csc
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

      @optional_fields = args
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
