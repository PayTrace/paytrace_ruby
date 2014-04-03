require 'paytrace/api/request'
require 'paytrace/api/gateway'
require 'paytrace/address'
module PayTrace
  module TransactionOperations
    def sale(args)
      create_transaction(args,TransactionTypes::SALE)
    end

    def authorization(args)
      create_transaction(args,TransactionTypes::Authorization)
    end

    def refund(args)
      create_transaction(args,TransactionTypes::Refund)
    end

    def void(transaction_id)
      params = {transaction_id: transaction_id}
      t = Transaction.new(type: TransactionTypes::Void,
                          optional:params)
      t.response = send_request(t)
      t
    end

    def forced_sale(approval_code,args)
      args[:approval_code] = approval_code
      create_transaction(args,TransactionTypes::ForcedSale)
    end

    def capture(transaction_id)
      params = {transaction_id: transaction_id}
      t = Transaction.new(type: TransactionTypes::Capture,
                          optional:params)
      t.response = send_request(t)
      t
    end

    def cash_advance(args)
      args[:cash_advance] = "Y"

      create_transaction(args,TransactionTypes::SALE)
    end

    def store_forward(amount,credit_card,optional={})
      optional[:amount] = amount
      optional[:credit_card] = credit_card
      create_transaction(optional,TransactionTypes::StoreForward)
    end

    private
    def create_transaction(args,type)
      amount = args.delete(:amount)  if args[:amount]
      cc = CreditCard.new(args.delete(:credit_card)) if args[:credit_card]
      customer = args.delete(:customer) if args[:customer]

      t = Transaction.new(amount: amount,
                          credit_card: cc,
                          customer: customer,
                          type: type,
                          optional:args)

      t.response = send_request(t)
      t
    end

    private
    def send_request(t)
      request = PayTrace::API::Request.new
      t.set_request(request)

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end

  end

  class Transaction
    class << self
      include TransactionOperations
    end

    attr_reader :amount, :credit_card, :type, :customer, :billing_address, :shipping_address,:optional_fields
    attr_accessor :response, :discretionary_data

    TRANSACTION_METHOD = "PROCESSTRANX"


    def set_shipping_same_as_billing()
        @shipping_address = @billing_address
    end



    def initialize(amount: nil, credit_card: nil, customer: nil, type: nil, optional: nil, discretionary_data: {} )
      @amount = amount
      @credit_card = credit_card
      @type = type
      @customer = customer
      @discretionary_data = discretionary_data || {}
      include_optional(optional) if optional
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

    private
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
        self.set_shipping_same_as_billing
      end

      @optional_fields = args
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
