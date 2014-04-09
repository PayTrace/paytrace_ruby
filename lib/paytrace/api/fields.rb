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
        return_bin: "RETURNBIN",
        enable_partial_authentication: "ENABLEPARTIALAUTH",
        custom_dba: "CUSTOMDBA",
        invoice:"INVOICE",
        transaction_id:"TRANXID",
        transaction_user:"USER",
        search_text:"SEARCHTEXT",
        check_id:"CHECKID",
        start_date:"SDATE",
        end_date:"EDATE",
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
        new_customer_id: "NEWCUSTID",
        customer_reference_id:"CUSTREF",
        customer_password:"CUSTPSWD",
        customer_fax:"FAX",
        customer_phone:"PHONE",
        approval_code:"APPROVAL",
        #cash advance
        cash_advance:"CASHADVANCE",
        id_number:"PHOTOID",
        id_expiration:"IDEXP",
        cc_last_4:"LAST4",
        #bank accounts
        account_number:"DDA",
        routing_number:"TR",
        #recurring transactions
        recur_id: "RECURID",
        recur_frequency: "FREQUENCY",
        recur_start: "START",
        recur_count: "TOTALCOUNT",
        recur_receipt: "CUSTRECEIPT",
        recur_type: "RECURTYPE",
        # attach signatures
        image_data: "IMAGEDATA",
        image_type: "IMAGETYPE"
      }
    end
  end
end
