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
        add_credit_card t.credit_card if t.credit_card
        add_customer t.customer if t.customer
        @params[:transaction_type] = t.type
        @params[:method] = TRANSACTION_METHOD
        @params[:amount] = t.amount
      end

      def add_credit_card(cc)
        @params[:card_number] = cc.card_number
        @params[:expiration_month] = cc.expiration_month
        @params[:expiration_year] = cc.expiration_year
      end

      def add_customer(c)
        @params[:customer_id] = c.customer_id
      end
    end
  end
end
