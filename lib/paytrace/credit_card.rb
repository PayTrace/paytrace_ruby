module PayTrace
  class CreditCard
    attr_accessor :card_number, :expiration_month, :expiration_year

    def initialize(options = {})
      @card_number = options[:card_number]
      @expiration_month = options[:expiration_month]
      @expiration_year = options[:expiration_year]
    end
  end
end
