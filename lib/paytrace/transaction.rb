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
      customer = Customer.new(customer_id: args.delete(:customer_id)) if args[:customer_id]

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
    attr_accessor :response

    TRANSACTION_METHOD = "PROCESSTRANX"


    def set_shipping_same_as_billing()
        @shipping_address = @billing_address
    end



    def initialize(amount: nil, credit_card: nil, customer: nil, type: nil, optional: nil )
      @amount = amount
      @credit_card = credit_card
      @type = type
      @customer = customer
      include_optional(optional) if optional
    end

    def set_request(request)
      add_transaction(request)
    end

    private
    def add_transaction(request)
      add_credit_card(request, credit_card) if credit_card
      add_customer(request, customer) if customer
      request.set_param(:transaction_type, type)
      request.set_param(:method, TRANSACTION_METHOD)
      request.set_param(:amount, amount)
      load_address(request)
      load_misc_fields(request) if optional_fields
    end

    def add_credit_card(request, cc)
      request.set_param(:card_number, cc.card_number) if cc.card_number
      request.set_param(:expiration_month, cc.expiration_month) if cc.expiration_month
      request.set_param(:expiration_year, cc.expiration_year) if cc.expiration_year
      request.set_param(:swipe, cc.swipe) if cc.swipe
      request.set_param(:csc, cc.csc) if cc.csc
    end


      def load_misc_fields(request)
        o = optional_fields
        o.each do |k,v|
          request.set_param(k, v)
        end


      end

      def load_address(request)
        add_shipping_address(request, shipping_address) if shipping_address
        add_billing_address(request, billing_address) if billing_address
      end

      def add_customer(request, c)
        request.set_param(:customer_id, c.customer_id)
      end

      def add_shipping_address(request, s)
        add_address(request, "shipping",s)
      end

      def add_billing_address(request, b)
        add_address(request, "billing",b)
      end

      def add_address(request, address_type, address)
        request.set_param(:"#{address_type}_name", address.name) if address.name
        request.set_param(:"#{address_type}_address", address.street) if address.street
        request.set_param(:"#{address_type}_address2", address.street2) if address.street2
        request.set_param(:"#{address_type}_city", address.city) if address.city
        request.set_param(:"#{address_type}_region", address.region) if address.region
        request.set_param(:"#{address_type}_state", address.state) if address.state
        request.set_param(:"#{address_type}_postal_code", address.postal_code) if address.postal_code
        request.set_param(:"#{address_type}_country", address.country) if address.country
      end


    def include_optional(args)
      s = nil
      b = nil

      b = args.delete(:billing_address)  if args[:billing_address]
      @billing_address = PayTrace::Address.new(b) if b
      s =  args.delete(:shipping_address) if args[:shipping_address]
      @shipping_address = PayTrace::Address.new(s) if s
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
