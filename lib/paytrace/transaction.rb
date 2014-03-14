require 'paytrace/api/request'
require 'paytrace/api/gateway'
require 'paytrace/address'
module PayTrace
  module TransactionOperations
    def sale(params)
      amount = params[:amount]
      cc = CreditCard.new(params[:credit_card]) if params[:credit_card]
      customer = Customer.new(customer_id: params[:customer_id]) if params[:customer_id]

      t = Transaction.new(amount: amount, 
                      credit_card: cc, 
                      customer: customer,
                      type: TransactionTypes::SALE,
                      optional:params)

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
    def include_optional(optional)

      b = optional[:billing_address]
      @billing_address = PayTrace::Address.new(b) if b
      s = optional[:shipping_address]
      @shipping_address = PayTrace::Address.new(s) if s
      if optional[:address_shipping_same_as_billing]
        self.set_shipping_same_as_billing
      end

      #clear these out so we have a clean hash
      optional[:billing_address] = nil
      optional[:shipping_address] = nil

      @optional_fields = optional

    end


  end

  module TransactionTypes
    SALE = "SALE"
  end

end
