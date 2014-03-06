require 'paytrace/api/request'
require 'paytrace/api/gateway'

module PayTrace
  module TransactionOperations
    def sale(amount: nil, 
             credit_card: nil, 
             customer_id: nil,
             options: {})

      cc = CreditCard.new(credit_card) if credit_card
      customer = Customer.new(customer_id: customer_id) if customer_id

      t = Transaction.new(amount: amount, 
                      credit_card: cc, 
                      customer: customer,
                      type: TransactionTypes::SALE)

      request = PayTrace::API::Request.new(transaction: t)
      gateway = PayTrace::API::Gateway.new
      t.response = gateway.send_request(request)
      t
    end
  end

  class Transaction
    class << self
      include TransactionOperations
    end

    attr_reader :amount, :credit_card, :type, :customer
    attr_accessor :response

    def initialize(amount: nil, credit_card: nil, customer: nil, type: nil)
      @amount = amount
      @credit_card = credit_card
      @type = type
      @customer = customer
    end

  end

  module TransactionTypes
    SALE = "SALE"
  end
end
