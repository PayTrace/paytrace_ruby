module PayTrace
  class Customer
    attr_accessor :customer_id

    def initialize(customer_id: nil)
      @customer_id = customer_id
    end
  end
end

