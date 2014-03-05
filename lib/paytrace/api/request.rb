module PayTrace
  module API
    class Request
      TRANSACTION_METHOD = "PROCESSTRANX"
      attr_reader :params, :field_delim, :value_delim

      def initialize(transaction: nil)
        @field_delim = "|"
        @value_delim = "~"

        @params= {
          user_name: PayTrace.configuration.user_name,
          password: PayTrace.configuration.password,
          terms: "Y"
        }

        add_transaction(transaction) if transaction
      end

      def to_parms_string()
        @params.map do |k,v|
          "#{PayTrace::API.fields.fetch(k)}#{@value_delim}#{v}"
        end.join(@field_delim) << "|"
      end

      private
      def add_transaction(t)
        @params[:card_number] = t.credit_card.card_number
        @params[:expiration_month] = t.credit_card.expiration_month
        @params[:expiration_year] = t.credit_card.expiration_year
        @params[:transaction_type] = t.type
        @params[:method] = TRANSACTION_METHOD
        @params[:amount] = t.amount
      end

    end
  end
end
