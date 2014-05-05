module PayTrace
  # Methods to request an email receipt for a transaction
  class EmailReceiptRequest
    # :nodoc:
    TRANSACTION_METHOD = "EmailReceipt"
    attr_accessor :email, :transaction_id, :check_id
    # :doc:

    # Initializer. Params:
    # *:email* -- the email address to send the receipt to
    # *:transaction_id* -- the transaction ID of the transaction to email
    # *:check_id* -- the check ID of the transaction to email
    # _Note:_ only use *:transaction_id* _or_ *:check_id* -- not both.
    def initialize(params = {})
      email, id, id_is_check_id = false
      @email = params[:email]
      @transaction_id = params[:transaction_id]
      @check_id = params[:check_id]
    end

    # :nodoc:
    def set_request(request = nil)
      request ||= PayTrace::API::Request.new
      request.set_param(:method, TRANSACTION_METHOD)
      request.set_param(:check_id, @check_id)
      request.set_param(:transaction_id, @transaction_id)
      request.set_param(:email, @email)

      request
    end
    # :doc:

    # Sends the request for the transaction. Accepts an existing request object, or creates one if needed.
    def send_request(request = nil)
      request ||= set_request

      gateway = PayTrace::API::Gateway.new
      gateway.send_request(request)
    end
  end
end
