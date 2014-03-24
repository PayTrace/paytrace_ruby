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
      request = PayTrace::API::Request.new(transaction: t)
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

    private
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
