module PayTrace
  module TransactionOperations
    def sale(amount: nil, credit_card: nil, options: {})
      Transaction.new(amount: amount, 
                      credit_card: credit_card, 
                      type: TransactionTypes::SALE)
    end
  end

  class Transaction
    class << self
      include TransactionOperations
    end

    attr_reader :amount, :credit_card, :type

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
