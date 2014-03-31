module PayTrace
  class Customer
    attr :id
    TRANSACTION_METHOD = "CreateCustomer"

    def initialize(id)
      @id = id
    end

    def self.from_cc_info(customer_id, credit_card, billing_address, shipping_address = nil, extra_customer_info = nil)
      request = get_request(customer_id)
      billing_address.set_request(request)
      request.set_param(:card_number, credit_card.card_number)
      request.set_param(:expiration_month, credit_card.expiration_month)
      request.set_param(:expiration_year, credit_card.expiration_year)
      
      build_customer(request, shipping_address, extra_customer_info)
    end

    def self.from_transaction_id(customer_id, transaction_id, billing_address = nil, shipping_address = nil, extra_customer_info = nil)
      request = get_request(customer_id)
      request.set_param(:transaction_id, transaction_id)

      # special case: we don't include BNAME for this call path
      if billing_address
        previous = billing_address.name
        billing_address.name = nil
        billing_address.set_request(request)
        billing_address.name = previous
      end

      build_customer(request, shipping_address, extra_customer_info)
    end

    def self.build_customer(request, shipping_address, extra_customer_info)
      shipping_address.set_request(request) if shipping_address
      add_extra_customer_info(request, extra_customer_info) if extra_customer_info
      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)
      new(response)
    end

    def self.add_extra_customer_info(request, info = {})
      request.set_param(:email, info[:email]) if info[:email]
      request.set_param(:customer_phone, info[:phone]) if info[:phone]
      request.set_param(:customer_fax, info[:fax]) if info[:fax]
      request.set_param(:customer_password, info[:customer_password]) if info[:customer_password]
      request.set_param(:account_number, info[:account_number]) if info[:account_number]
      request.set_param(:routing_number, info[:routing_number]) if info[:routing_number]
      request.set_param(:discretionary_data, info[:discretionary_data]) if info[:discretionary_data]
    end

    def self.get_request(customer_id)
      request = PayTrace::API::Request.new
      request.set_param(:method, TRANSACTION_METHOD)
      request.set_param(:customer_id, customer_id) 

      request   
    end

    private_class_method :add_extra_customer_info, :get_request, :build_customer
  end
end

