module PayTrace
  module API
    def self.fields
      {
        amount: "AMOUNT",
        method: "METHOD",
        password: "PSWD",
        terms: "TERMS",
        transaction_type: "TRANXTYPE",
        user_name: "UN",
        email: "EMAIL",
        description: "DESCRIPTION",
        tax_amount: "TAX",
        return_clr: "RETURNCLR",
        enable_partial_authentication: "ENABLEPARTIALAUTH",
        discretionary_data: "DISCRETIONARY DATA",
        custom_dba: "CUSTOMDBA",

        #credit card
        card_number: "CC",
        expiration_year: "EXPYR",
        expiration_month: "EXPMNTH",
        csc: "CSC",
        swipe:"SWIPE",
        #billing address
        billing_name: "BNAME",
        billing_address: "BADDRESS",
        billing_address2:"BADDRESS2",
        billing_city: "BCITY",
        billing_state: "BSTATE",
        billing_postal_code: "BZIP",
        billing_country: "BCOUNTRY",
        #shipping_address
        shipping_name: "SNAME",
        shipping_address: "SADDRESS",
        shipping_address2:"SADDRESS2",
        shipping_city: "SCITY",
        shipping_state: "SSTATE",
        shipping_postal_code: "SZIP",
        shipping_region: "SCOUNTY",
        shipping_country: "SCOUNTRY",
        #customer
        customer_id: "CUSTID",
        customer_reference_id:"CUSTREF",

        invoice:"INVOICE",
      }
    end
  end
end
