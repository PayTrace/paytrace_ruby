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
      }
    end
  end
end
