module PayTrace
  module API
    # Friendly names for API methods and parameters
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
        national_tax: "NTAX",
        new_password: "NEWPSWD",
        new_password_confirmation: "NEWPSWD2",
        # level 3 stuff
        merchant_tax_id: "MERCHANTTAXID",
        customer_tax_id: "CUSTOMERTAXID",
        ccode: "CCODE",
        line_item: "LINEITEM",
        line_items: "LINEITEMS",
        ccode_li: "CCODELI",
        discount: "DISCOUNT",
        freight: "FREIGHT",
        duty: "DUTY",
        add_tax: "ADDTAX",
        add_tax_rate: "ADDTAXRATE",
        product_id: "PRODUCTID",
        quantity: "QUANTITY",
        measure: "MEASURE",
        unit_cost: "UNITCOST",
        additional_tax_included: "ADDTAXIND",
        additional_tax_included_li: "ADDTAXINDLI",
        add_tax_li: "ADDTAXLI",
        add_tax_rate_li: "ADDTAXRATELI",
        discount_li: "DISCOUNTLI",
        amount_li: "AMOUNTLI",
        discount_included: "DISCOUNTIND",
        line_item_is_gross: "NETGROSSIND",
        is_debit_or_credit: "DCIND",
        discount_rate: "DISCOUNTRATE",

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
        store_forward_date:"STRFWDDATE",
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
        days_inactive:"DAYS",
        #cash advance
        cash_advance:"CASHADVANCE",
        id_number:"PHOTOID",
        id_expiration:"IDEXP",
        cc_last_4:"LAST4",
        #bank accounts/checks
        account_number:"DDA",
        routing_number:"TR",
        check_type: "CHECKTYPE",
        #recurring transactions
        recur_id: "RECURID",
        recur_frequency: "FREQUENCY",
        recur_start: "START",
        recur_count: "TOTALCOUNT",
        recur_receipt: "CUSTRECEIPT",
        recur_type: "RECURTYPE",
        recur_next: "NEXT",
        # attach signatures
        image_data: "IMAGEDATA",
        image_type: "IMAGETYPE",
        source_zip: "SOURCEZIP",
        source_state: "SOURCESTATE",
        shipping_weight: "WEIGHT",
        shippers: "SHIPPERS",
        # batch opterations
        batch_number: "BATCHNUMBER",
        # test flag
        test_flag: "TEST"
      }
    end
  end
end
