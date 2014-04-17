require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Transaction do
  describe "add level 3 data" do
    def base_url(method)
      "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~#{method}|"
    end

    before do
      PayTrace::API::Gateway.debug = true
      PayTrace::API::Gateway.next_response = "RESPONSE~ok|RECURID~12345|"
    end

    # see http://help.paytrace.com/api-adding-level-3-data-to-a-visa-sale

    # Required Name Value Pairs

    # UN, PSWD, TERMS, METHOD, TRANXID

    # Optional Name Value Pairs For Add Level 3 Data to Visa Request

    # INVOICE, CUSTREF, TAX, NTAX, MERCHANTTAXID, CUSTOMERTAXID, CCODE, DISCOUNT, FREIGHT, DUTY, SOURCEZIP, SZIP, SCOUNTRY, ADDTAX, ADDTAXRATE

    # Optional Name Value Pairs For Line Item Detail to Visa Request

    # CCODELI, PRODUCTID, DESCRIPTION, QUANTITY, MEASURE, UNITCOST, ADDTAXLI, ADDTAXRATELI, DISCOUNTLI, AMOUNTLI

    # Please note that each name/value pair is separated by the traditional ~ and followed by a |. However, name/value pairs included in the LINEITEM parameter are separated by the = symbol and followed by a + symbol. So, no values in a Level3Visa request should contain a ~, |, +, or = symbols. The example request below contains 1 Line Item record.
    it "works with visa" do
      params = {
        transaction_id: "1143",
        invoice: "12346",
        customer_reference_id: "1234578",
        tax_amount: 31.76,
        national_tax: "0.00",
        merchant_tax_id: "13692468",
        customer_tax_id: "12369240",
        ccode: "1234abcd",
        discount: 4.53,
        freight: 7.99,
        duty: 6.52,
        source_zip: "94947",
        shipping_postal_code: "98133",
        shipping_country: "US",
        add_tax: 4.78,
        add_tax_rate: 0.43,
        line_items: 
        [
          {
            ccode_li: "12345678",
            product_id: "E123125",
            description: "Widgets and wodgets",
            quantity: 20,
            measure: "foo",
            unit_cost: 3.99,
            add_tax_li: 3.82,
            add_tax_rate_li: 0.44,
            discount_li: 1.86,
            amount_li: 5
            },
          {
            ccode_li: "12345679",
            product_id: "D987654",
            description: "It's log!",
            quantity: 42,
            measure: "bar",
            unit_cost: 3.98,
            add_tax_li: 3.81,
            add_tax_rate_li: 0.45,
            discount_li: 1.87,
            amount_li: 6
            }
          ]
      }
      PayTrace::Transaction.add_level_three_visa(params)

      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::Transaction::LEVEL_3_VISA_METHOD) + 
        "TRANXID~1143|INVOICE~12346|CUSTREF~1234578|TAX~31.76|NTAX~0.00|MERCHANTTAXID~13692468|CUSTOMERTAXID~12369240|CCODE~1234abcd|DISCOUNT~4.53|FREIGHT~7.99|DUTY~6.52|SOURCEZIP~94947|SZIP~98133|SCOUNTRY~US|ADDTAX~4.78|ADDTAXRATE~0.43|LINEITEM~CCODELI=12345678+PRODUCTID=E123125+DESCRIPTION=Widgets and wodgets+QUANTITY=20+MEASURE=foo+UNITCOST=3.99+ADDTAXLI=3.82+ADDTAXRATELI=0.44+DISCOUNTLI=1.86+AMOUNTLI=5|LINEITEM~CCODELI=12345679+PRODUCTID=D987654+DESCRIPTION=It's log!+QUANTITY=42+MEASURE=bar+UNITCOST=3.98+ADDTAXLI=3.81+ADDTAXRATELI=0.45+DISCOUNTLI=1.87+AMOUNTLI=6|"
    end

  # Required Name Value Pairs

  # UN, PSWD, TERMS, METHOD, TRANXID

  # Optional Name Value Pairs For Add Level 3 Data to MasterCard Request

  # INVOICE, CUSTREF, TAX, NTAX, FREIGHT, DUTY, SOURCEZIP, SZIP, SCOUNTRY, ADDTAX, ADDTAXIND

  # Optional Name Value Pairs For Line Item Detail to MasterCard Request

  # PRODUCTID, DESCRIPTION, QUANTITY, MEASURE, MERCHANTTAXID, UNITCOST, ADDTAXRATELI, ADDTAXINDLI, ADDTAXLI, AMOUNTLI, DISCOUNTIND, NETGROSSIND, DCIND, DISCOUNTLI, DICOUNTRATE

    # see http://help.paytrace.com/api-adding-level-3-data-to-a-mastercard-sale
    it "works with mastercard" do
      params = {
        transaction_id: "1143",
        invoice: "12347",
        customer_reference_id: "1234579",
        tax_amount: 31.78,
        national_tax: 0.01,
        freight: 7.98,
        duty: 6.51,
        source_zip: "94948",
        shipping_postal_code: "98134",
        shipping_country: "US",
        add_tax: 4.54,
        additional_tax_included: 'Y',
        line_items: 
        [
          {
            product_id: "E123126",
            description: "Wadgets and wudgets",
            quantity: 21,
            measure: "food",
            merchant_tax_id: "13699468",
            unit_cost: 3.98,
            add_tax_rate_li: 0.45,
            additional_tax_included_li: 'Y',
            add_tax_li: 3.82,
            discount_included: 'Y',
            amount_li: 6,
            line_item_is_gross: 'Y',
            is_debit_or_credit: 'D',
            discount_li: 1.86,
            discount_rate: '0.10'
            }
          ]
      }

      PayTrace::Transaction.add_level_three_mc(params)

      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::Transaction::LEVEL_3_MC_METHOD) + 
        "TRANXID~1143|INVOICE~12347|CUSTREF~1234579|TAX~31.78|NTAX~0.01|FREIGHT~7.98|DUTY~6.51|SOURCEZIP~94948|SZIP~98134|SCOUNTRY~US|ADDTAX~4.54|ADDTAXIND~Y|LINEITEM~PRODUCTID=E123126+DESCRIPTION=Wadgets and wudgets+QUANTITY=21+MEASURE=food+MERCHANTTAXID=13699468+UNITCOST=3.98+ADDTAXRATELI=0.45+ADDTAXINDLI=Y+ADDTAXLI=3.82+DISCOUNTIND=Y+AMOUNTLI=6+NETGROSSIND=Y+DCIND=D+DISCOUNTLI=1.86+DISCOUNTRATE=0.10|"
    end
  end
end