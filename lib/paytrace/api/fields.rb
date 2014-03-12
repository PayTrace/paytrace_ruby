module PayTrace
  module API
    def self.fields
      {
        amount: "AMOUNT",
        card_number: "CC",
        expiration_year: "EXPYR",
        expiration_month: "EXPMNTH",
        method: "METHOD",
        password: "PSWD",
        terms: "TERMS",
        transaction_type: "TRANXTYPE",
        user_name: "UN",
        customer_id: "CUSTID",
        #billing address
        billing_name: "BNAME",
        billing_address: "BADDRESS",
        billing_address2:"BADDRESS2",
        billing_city: "BCITY",
        billing_state: "BState",
        billing_postal_code: "BZIP",
        billing_country: "BCountry"
      }
    end
  end
end
