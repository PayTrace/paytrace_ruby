module PayTrace
  # Methods to request an email receipt for a transaction
  class EmailReceiptRequest
    # :nodoc:
    EMAIL_RECEIPT_METHOD = "EmailReceipt"
    # :doc:

    # Send the request. Params:
    # *:email* -- the email address to send the receipt to
    # *:transaction_id* -- the transaction ID of the transaction to email
    # *:check_id* -- the check ID of the transaction to email
    # _Note:_ only use *:transaction_id* _or_ *:check_id* -- not both.
    def self.create(params = {})
      PayTrace::API::Gateway.send_request(EMAIL_RECEIPT_METHOD, [:check_id, :transaction_id, :email], params)
    end
  end
end
