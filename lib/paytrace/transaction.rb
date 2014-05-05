require 'paytrace/api/request'
require 'paytrace/api/gateway'
require 'paytrace/address'
require 'base64'

module PayTrace
  class Transaction
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

    def self.sale(args)
      create_transaction(args,TransactionTypes::SALE)
    end

    def self.authorization(args)
      create_transaction(args,TransactionTypes::Authorization)
    end

    def self.refund(args)
      create_transaction(args,TransactionTypes::Refund)
    end

    def self.void(transaction_id)
      params = {transaction_id: transaction_id}
      t = Transaction.new({type: TransactionTypes::Void,
                          optional:params})
      t.response = t.send_request
      t
    end

    def self.forced_sale(approval_code,args)
      args[:approval_code] = approval_code
      create_transaction(args,TransactionTypes::ForcedSale)
    end

    def self.capture(transaction_id)
      t = Transaction.new({transaction_id: transaction_id, type: TransactionTypes::Capture,
                          optional:params})
      t.response = t.send_request
      t
    end

    def self.cash_advance(args)
      args[:cash_advance] = "Y"

      create_transaction(args,TransactionTypes::SALE)
    end

    def self.store_forward(amount,credit_card,optional={})
      optional[:amount] = amount
      optional[:credit_card] = credit_card
      create_transaction(optional,TransactionTypes::StoreForward)
    end

    def self.create_transaction(args,type)
      amount = args.delete(:amount)  if args[:amount]
      cc = CreditCard.new(args.delete(:credit_card)) if args[:credit_card]
      customer = args.delete(:customer) if args[:customer]

      t = Transaction.new({amount: amount,
                          credit_card: cc,
                          customer: customer,
                          type: type,
                          optional:args})

      
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
