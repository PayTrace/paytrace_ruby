module PayTrace
  module TransactionOperations
    def sale(amount: nil, credit_card: nil, options: {})
      Transaction.new(amount: amount, credit_card: credit_card)
    end
  end

  class Transaction
    class << self
      include TransactionOperations
    end

    attr_reader :amount, :credit_card

    def initialize(amount: nil, credit_card: nil)
      @amount = amount
      @credit_card = CreditCard.new(credit_card)
    end
  end
end
