$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"

PayTrace::Debug.configure_test

PayTrace::Debug.trace do
  params = {
    transaction_id: "1143",
    invoice: "12346",
    customer_reference_id: "1234578",
    tax_amount: 31.76,
    ntax: 0.00,
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
end

# https://stage.paytrace.com/api/default.pay?parmList=UN~NEWapiuser%7CPSWD~test456%7CTERMS~Y%7CMETHOD~Level3MCRD%7CTRANXID~1399%7CINVOICE~12347%7CCUSTREF~1234579%7CTAX~31.78%7CNTAX~0.01%7CFREIGHT~7.98%7CDUTY~6.51%7CSOURCEZIP~94948%7CSZIP~98134%7CSCOUNTRY~US%7CADDTAX~4.54%7CADDTAXIND~Y%7CLINEITEM~PRODUCTID=E123126+DESCRIPTION=Wadgets%20and%20wudgets+QUANTITY=21+MEASURE=food+MERCHANTTAXID=13699468+UNITCOST=3.98+ADDTAXRATELI=0.45+ADDTAXINDLI=Y+ADDTAXLI=3.82+DISCOUNTIND=Y+AMOUNTLI=6+NETGROSSIND=Y+DCIND=D+DISCOUNTLI=1.86+DISCOUNTRATE=0.10%7C
# [REQUEST] UN~demo123|PSWD~demo123|TERMS~Y|METHOD~Level3MCRD|TRANXID~1399|INVOICE~12347|CUSTREF~1234579|TAX~31.78|NTAX~0.01|FREIGHT~7.98|DUTY~6.51|SOURCEZIP~94948|SZIP~98134|SCOUNTRY~US|ADDTAX~4.54|ADDTAXIND~Y|LINEITEM~PRODUCTID=E123126+DESCRIPTION=Wadgets and wudgets+QUANTITY=21+MEASURE=food+MERCHANTTAXID=13699468+UNITCOST=3.98+ADDTAXRATELI=0.45+ADDTAXINDLI=Y+ADDTAXLI=3.82+DISCOUNTIND=Y+AMOUNTLI=6+NETGROSSIND=Y+DCIND=D+DISCOUNTLI=1.86+DISCOUNTRATE=0.10|

PayTrace::Debug.configure_test("NEWapiuser", "test456")
PayTrace::Debug.trace do
  params = {
      transaction_id: "1399",
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
          discount_li: 1.86
          }
        ]
    }

  PayTrace::Transaction.add_level_three_mc(params)
end