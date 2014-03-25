module PayTrace
  class EmailReceiptRequest
    TRANSACTION_METHOD = "EmailReceipt"
    attr_accessor :email, :id, :id_is_check_id

    def initialize(email, id, id_is_check_id = false)
      @email = email
      @id = id
      @id_is_check_id = id_is_check_id
    end

    def set_request(request = nil)
      request ||= PayTrace::API::Request.new
      request.set_param(:method, TRANSACTION_METHOD)
      if @id_is_check_id
        request.set_param(:check_id, @id)
      else
        request.set_param(:transaction_id, @id)
      end
      request.set_param(:email, @email)

      request
    end

    def send_request(request = nil)
      request ||= set_request

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end
  end
end