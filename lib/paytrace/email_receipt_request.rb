module PayTrace
  class EmailReceiptRequest
    TRANSACTION_METHOD = "EmailReceipt"
    attr_accessor :email, :transaction_id, :check_id

    def initialize(params = {})
      email, id, id_is_check_id = false
      @email = params[:email]
      @transaction_id = params[:transaction_id]
      @check_id = params[:check_id]
    end

    def set_request(request = nil)
      request ||= PayTrace::API::Request.new
      request.set_param(:method, TRANSACTION_METHOD)
      request.set_param(:check_id, @check_id)
      request.set_param(:transaction_id, @transaction_id)
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
