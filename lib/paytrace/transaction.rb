require 'paytrace/api/request'
require 'paytrace/api/gateway'

module PayTrace
  module TransactionOperations
    def sale(amount: nil, credit_card: nil, options: {})
      t = Transaction.new(amount: amount, 
                      credit_card: credit_card, 
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

    attr_reader :amount, :credit_card, :type
    attr_accessor :response

    def initialize(amount: nil, credit_card: nil, type: nil)
      @amount = amount
      @credit_card = CreditCard.new(credit_card)
      @type = type
    end

  end

  module TransactionTypes
    SALE = "SALE"
  end
end
