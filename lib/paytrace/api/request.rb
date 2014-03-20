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
        load_address(t)
        load_optional_fields(t) if t.optional_fields
      end

      def add_credit_card(cc)
        @params[:card_number] = cc.card_number if cc.card_number
        @params[:expiration_month] = cc.expiration_month if cc.expiration_month
        @params[:expiration_year] = cc.expiration_year if cc.expiration_year
        @params[:swipe] = cc.swipe if cc.swipe
        @params[:csc] = cc.csc if cc.csc
      end

      def load_optional_fields(t)
        o = t.optional_fields
        @params[:email] = o[:email] if o[:email]
        @params[:description] = o[:description] if o[:description]
        @params[:tax_amount] = o[:tax_amount] if o[:tax_amount]
        @params[:return_clr] = o[:return_clr] if o[:return_clr]
        @params[:enable_partial_authentication] = o[:enable_partial_authentication] if o[:enable_partial_authentication]
        @params[:discretionary_data] = o[:discretionary_data] if o[:discretionary_data]
        @params[:custom_dba] = o[:custom_dba] if o[:custom_dba]
        @params[:invoice] = o[:invoice] if o[:invoice]
        @params[:transaction_id] = o[:transaction_id] if o[:transaction_id]
        @params[:customer_reference_id] = o[:customer_reference_id] if o[:customer_reference_id]
        @params[:approval_code] = o[:approval_code] if o[:approval_code]
      end

      def load_address(t)
        add_shipping_address(t.shipping_address) if t.shipping_address
        add_billing_address(t.billing_address) if t.billing_address
      end

      def add_customer(c)
        @params[:customer_id] = c.customer_id
      end

      def add_shipping_address(s)
         add_address("shipping",s)
      end

      def add_billing_address(b)
        add_address("billing",b)
      end

      def add_address(address_type, address)
        @params[:"#{address_type}_name"] = address.name if address.name
        @params[:"#{address_type}_address"] = address.street if address.street
        @params[:"#{address_type}_address2"] = address.street2 if address.street2
        @params[:"#{address_type}_city"] = address.city if address.city
        @params[:"#{address_type}_region"] = address.region if address.region
        @params[:"#{address_type}_state"] = address.state if address.state
        @params[:"#{address_type}_postal_code"] = address.postal_code if address.postal_code
        @params[:"#{address_type}_country"] = address.country if address.country

      end


    end
  end
end
