module PayTrace
  # Contains credit card information, including possible swipe data.
  class CreditCard
    attr_accessor :card_number, :expiration_month, :expiration_year, :swipe, :csc

    # Initialize instance; possible options are: 
    # * *card_number* -- the credit card number
    # * *expiration_month* -- the expiration month of the card
    # * *expiration_year* -- the expiration year of the card
    # * *csc* -- the CSC code
    # * *swipe* -- swipe data, if present
    # All parameters are passed in a hash, with symbols for key names.
    def initialize(options={})

      @card_number = options[:card_number]
      @expiration_month = options[:expiration_month]
      @expiration_year = options[:expiration_year]
      @swipe = options[:swipe]
      @csc = options[:csc]
    end
  end
end
