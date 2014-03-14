module PayTrace
  class CreditCard
    attr_accessor :card_number, :expiration_month, :expiration_year, :swipe, :csc

    def initialize(options = {})
      @card_number = options[:card_number]
      @expiration_month = options[:expiration_month]
      @expiration_year = options[:expiration_year]
      @swipe = options[:swipe]
      @csc = options[:csc]
    end
  end
end
