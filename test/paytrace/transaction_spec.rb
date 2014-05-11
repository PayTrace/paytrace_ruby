require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Transaction do
  before do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.reset_trace()
    PayTrace::API::Gateway.next_response = "RESPONSE~ok|"
  end

  describe "export transactions" do
    it "exports transaction(s)" do
      PayTrace::API::Gateway.next_response = "TRANSACTIONRECORD~TRANXID=1143"
      records = PayTrace::Transaction.export_by_id({transaction_id: 1143})
      records.must_be_instance_of Array
      records.count.must_equal 1
      records[0].must_be_instance_of Hash
      records[0]["TRANXID"].must_equal "1143"

      assert_last_request_equals "METHOD~ExportTranx|TRANXID~1143|"
    end

    it "it can export transactions by date range" do
      PayTrace::API::Gateway.next_response = "TRANSACTIONRECORD~TRANXID=1144|TRANSACTIONRECORD~TRANXID=1145|"

      params = {
        start_date: '01/02/2013',
        end_date: '01/03/2014',
        transaction_type: 'SETTLED',
        customer_id: 1234,
        transaction_user: 'DDuck',
        return_bin: 'Y',
        search_text: 'search text'
      }

      records = PayTrace::Transaction.export_by_date_range(params)
      records.must_be_instance_of Array
      records.count.must_equal 2
      records[0].must_be_instance_of Hash
      records[0]["TRANXID"].must_equal "1144"

      assert_last_request_equals "METHOD~ExportTranx|SDATE~01/02/2013|EDATE~01/03/2014|TRANXTYPE~SETTLED|CUSTID~1234|USER~DDuck|RETURNBIN~Y|SEARCHTEXT~search text|"
    end
  end

  describe "settle transactions" do
    it "can settle transactions" do
      PayTrace::Transaction.settle_transactions()

      assert_last_request_equals "METHOD~SettleTranx|"
    end
  end

  it "successfully attaches image files to transactions as signatures" do
    PayTrace::API::Gateway.next_response = "RESPONSE~172. The signature image was successfully attached to Transaction ID 13192003.|"
    result = PayTrace::Transaction.attach_signature_file({transaction_id: 13192003, image_file: __FILE__, image_type: "png"})
    result.has_errors?.must_equal false
  end

  it "successfully attaches image data to transactions as signatures" do
    PayTrace::API::Gateway.next_response = "RESPONSE~172. The signature image was successfully attached to Transaction ID 13192003.|"
    result = PayTrace::Transaction.attach_signature_data({transaction_id: 13192003, image_data: "fakebase64data", image_type: "png"})
    result.has_errors?.must_equal false

    assert_last_request_equals "METHOD~AttachSignature|TRANXID~13192003|IMAGEDATA~fakebase64data|IMAGETYPE~png"
  end

  it "calculates shipping costs" do
    PayTrace::API::Gateway.next_response = "SHIPPINGRECORD~SHIPPINGCOMPANY=USPS+SHIPPINGMETHOD=STANDARD POST+SHIPPINGRATE=12.72|"
    params = {
      source_zip: 98133,
      source_state: "WA", 
      shipping_postal_code: 94947,
      shipping_weight: 5.1,
      shippers: "UPS,USPS,FEDEX",
      shipping_state: "CA"
    }
    result = PayTrace::Transaction.calculate_shipping(params)
    result[0]['SHIPPINGCOMPANY'].must_equal "USPS"

    assert_last_request_equals "METHOD~CalculateShipping|SOURCEZIP~98133|SOURCESTATE~WA|SZIP~94947|WEIGHT~5.1|SHIPPERS~UPS,USPS,FEDEX|SSTATE~CA|"
  end

  it "can adjust a transaction" do
    PayTrace::API::Gateway.next_response = "SHIPPINGRECORD~SHIPPINGCOMPANY=USPS+SHIPPINGMETHOD=STANDARD POST+SHIPPINGRATE=12.72|"
    params = {
      transaction_id: 1234,
      amount: 9.87
    }
    result = PayTrace::Transaction.adjust_amount(params)
    assert_last_request_equals "METHOD~AdjustAmount|TRANXID~1234|AMOUNT~9.87|"
  end

  describe "create sales transactions" do
    it "can create a payment authorization for a keyed credit card" do
      PayTrace::Transaction.keyed_authorization({ 
        amount:"1242.32",
        card_number:"1234123412341234",
        expiration_month:10,
        expiration_year:24
      })

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Authorization|AMOUNT~1242.32|CC~1234123412341234|EXPMNTH~10|EXPYR~24|"
    end

    it "can create a payment authorization based upon a customer ID" do
      PayTrace::Transaction.customer_id_authorization({ 
        amount:"1242.32",
        customer_id: 1234
      })

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Authorization|AMOUNT~1242.32|CUSTID~1234|"
    end

    it "can charge sales to a swiped credit card" do
      PayTrace::Transaction.swiped_sale({
        amount: "1242.32",
        swipe: "this is fake swipe data"
      })

      assert_last_request_equals "METHOD~PROCESSTRANX|AMOUNT~1242.32|TRANXTYPE~SALE|SWIPE~this is fake swipe data|"
    end

    it "can charge sales to a keyed credit card" do
      PayTrace::Transaction.keyed_sale({
        amount: "1242.32",
        card_number: "1234123412341234",
        expiration_month: 10,
        expiration_year:  24
      })

      assert_last_request_equals "METHOD~PROCESSTRANX|AMOUNT~1242.32|TRANXTYPE~SALE|CC~1234123412341234|EXPMNTH~10|EXPYR~24|"
    end

    it "can run a transaction for a customer" do
      PayTrace::Transaction.customer_id_sale(
          {amount: "1.00",
           customer_id: 123456}
      )

      assert_last_request_equals "METHOD~PROCESSTRANX|AMOUNT~1.00|TRANXTYPE~SALE|CUSTID~123456|"
    end
  end

  describe "cash advance" do
    it "can perform a cash advance for swiped credit card data" do
      args = {
        amount:"1.00",
        cc_last_4:"1234",
        id_number:"12345",
        id_expiration:"12/29/2020",
        billing_name: "John Doe",
        billing_address: "1234 happy lane",
        billing_address2: "apt #1",
        billing_city: "Seattle",
        billing_state: "WA",
        billing_postal_code:"98107",
        billing_country:"US",
        swipe:'%B5454545454545454^J/SCOTT^2612101001020001000000701000000?;5454545454545454=26121010010270100001?'
        }
      
      PayTrace::Transaction.swiped_cash_advance(args)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~SALE|AMOUNT~1.00|LAST4~1234|PHOTOID~12345|IDEXP~12/29/2020|CASHADVANCE~Y|BNAME~John Doe|BADDRESS~1234 happy lane|BADDRESS2~apt #1|BCITY~Seattle|BSTATE~WA|BZIP~98107|BCOUNTRY~US|SWIPE~%B5454545454545454^J/SCOTT^2612101001020001000000701000000?;5454545454545454=26121010010270100001?"
    end

    it "can perform a cash advance for keyed-in credit card data" do
      args = {
        amount:"1.00",
        cc_last_4:"1234",
        id_number:"12345",
        id_expiration:"12/29/2020",
        billing_name: "John Doe",
        billing_address: "1234 happy lane",
        billing_address2: "apt #1",
        billing_city: "Seattle",
        billing_state: "WA",
        billing_postal_code:"98107",
        billing_country:"US",
        card_number: 1234123412341234,
        expiration_month: 10,
        expiration_year: 24
      }
      
      PayTrace::Transaction.keyed_cash_advance(args)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~SALE|AMOUNT~1.00|LAST4~1234|PHOTOID~12345|IDEXP~12/29/2020|CASHADVANCE~Y|BNAME~John Doe|BADDRESS~1234 happy lane|BADDRESS2~apt #1|BCITY~Seattle|BSTATE~WA|BZIP~98107|BCOUNTRY~US|CC~1234123412341234|EXPMNTH~10|EXPYR~24|"
    end
  end

  describe "store and forward transactions" do
    it "can perform a store and forward transaction for swiped credit card data" do
      params = {amount: 19.97, swipe: 'this is fake swipe data'}
      PayTrace::Transaction.swiped_store_forward(params)

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Str/FWD|AMOUNT~19.97|SWIPE~this is fake swipe data|"
    end

    it "can perform a store and forward transaction for keyed-in credit card data" do
      params = {amount: 19.96, card_number: 1234123412341234, expiration_month: 10, expiration_year: 24}
      PayTrace::Transaction.keyed_store_forward(params)

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Str/FWD|AMOUNT~19.96|CC~1234123412341234|EXPMNTH~10|EXPYR~24|"
    end

    it "can perform a store and forward transaction referencing a customer id" do
      params = {amount: 19.96, customer_id: 1234}
      PayTrace::Transaction.customer_id_store_forward(params)

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Str/FWD|AMOUNT~19.96|CUSTID~1234|"
    end

    it "accepts extra parameters" do
      params = {
        amount: 19.96, 
        customer_id: 1234,
        billing_name: "John Doe",
        billing_address: "1234 Fake St.",
        billing_address2: "Suite 123",
        billing_city: "Seattle",
        billing_state: "WA",
        billing_postal_code: "98133",
        billing_country: "US",
        shipping_name: "Jim Doe",
        shipping_address: "1235 Fake Ave.",
        shipping_address2: "Suite 345",
        shipping_city: "Shoreline",
        shipping_state: "WA",
        shipping_postal_code: "98134",
        shipping_region: "King County",
        shipping_country: "US",
        email: "support@paytrace.com",
        csc: 993,
        invoice: "fake_invoice",
        description: "fake_description",
        tax_amount: 19.98,
        customer_reference_id: "cust_ref_id",
        discretionary_data: {hair_color: "red"},
        return_clr: "Y",
        custom_dba: "Arcadian Productions",
        enable_partial_authentication: "Y"
      }
      PayTrace::Transaction.customer_id_store_forward(params)

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Str/FWD|AMOUNT~19.96|CUSTID~1234|BNAME~John Doe|BADDRESS~1234 Fake St.|BADDRESS2~Suite 123|BCITY~Seattle|BSTATE~WA|BZIP~98133|BCOUNTRY~US|SNAME~Jim Doe|SADDRESS~1235 Fake Ave.|SADDRESS2~Suite 345|SCITY~Shoreline|SSTATE~WA|SZIP~98134|SCOUNTY~King County|SCOUNTRY~US|EMAIL~support@paytrace.com|CSC~993|INVOICE~fake_invoice|DESCRIPTION~fake_description|TAX~19.98|CUSTREF~cust_ref_id|RETURNCLR~Y|CUSTOMDBA~Arcadian Productions|ENABLEPARTIALAUTH~Y|hair_color~red"
    end
  end

  describe "refund transactions" do
    it "can create a refund transaction for a swiped credit card" do
      params = {
        amount: 19.99,
        swipe: 'this is fake swipe data'
      }

      PayTrace::Transaction.swiped_refund(params)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Refund|AMOUNT~19.99|SWIPE~this is fake swipe data|"
    end

    it "can create a refund transaction for a keyed-in credit card" do
      params = {
        amount: 19.99,
        card_number: 5444444444444444,
        expiration_month: 10,
        expiration_year: 24
      }

      PayTrace::Transaction.keyed_refund(params)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Refund|AMOUNT~19.99|CC~5444444444444444|EXPMNTH~10|EXPYR~24|"
    end

    it "can create a refund transaction for a particular customer ID" do
      params = {
        amount: 19.99,
        customer_id: 1234
      }

      PayTrace::Transaction.customer_id_refund(params)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Refund|AMOUNT~19.99|CUSTID~1234|"
    end

    it "can create a refund transaction for a particular transaction ID" do
      params = {
        amount: 19.99,
        transaction_id: 1234
      }

      PayTrace::Transaction.transaction_id_refund(params)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Refund|AMOUNT~19.99|TRANXID~1234|"
    end

    it "accepts optional data" do
      params = {
        amount: 19.99,
        transaction_id: 1234,
        billing_name: "John Doe",
        billing_address: "1234 Fake St.",
        billing_address2: "Suite 123",
        billing_city: "Seattle",
        billing_state: "WA",
        billing_postal_code: "98133",
        billing_country: "US",
        shipping_name: "Jim Doe",
        shipping_address: "1235 Fake Ave.",
        shipping_address2: "Suite 345",
        shipping_city: "Shoreline",
        shipping_state: "WA",
        shipping_postal_code: "98134",
        shipping_region: "King County",
        shipping_country: "US",
        email: "support@paytrace.com",
        csc: 993,
        invoice: "fake_invoice",
        description: "fake_description",
        tax_amount: 19.98,
        customer_reference_id: "cust_ref_id",
        discretionary_data: {hair_color: "red"}
      }

      PayTrace::Transaction.transaction_id_refund(params)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Refund|AMOUNT~19.99|TRANXID~1234|BNAME~John Doe|BADDRESS~1234 Fake St.|BADDRESS2~Suite 123|BCITY~Seattle|BSTATE~WA|BZIP~98133|BCOUNTRY~US|SNAME~Jim Doe|SADDRESS~1235 Fake Ave.|SADDRESS2~Suite 345|SCITY~Shoreline|SSTATE~WA|SZIP~98134|SCOUNTY~King County|SCOUNTRY~US|EMAIL~support@paytrace.com|CSC~993|INVOICE~fake_invoice|DESCRIPTION~fake_description|TAX~19.98|CUSTREF~cust_ref_id|hair_color~red"
    end
  end

  describe "adding address info" do
    it "can take a shipping address" do
        PayTrace::Transaction.customer_id_sale({
        amount: 19.99,
        customer_id: 'MMouse',
        shipping_name: "Joe Blow",
        shipping_address: "1234 happy lane",
        shipping_address2: "suit 234",
        shipping_city:"Seattle",
        shipping_state:"WA",
        shipping_country:"USA",
        shipping_postal_code:"98107"
      })

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~SALE|AMOUNT~19.99|CUSTID~MMouse|SNAME~Joe Blow|SADDRESS~1234 happy lane|SADDRESS2~suit 234|SCITY~Seattle|SSTATE~WA|SCOUNTRY~USA|SZIP~98107|"
    end

    it "can take a billing address" do
      PayTrace::Transaction.customer_id_sale({
        amount: 19.99,
        customer_id: 'MMouse',
        billing_name: "Joe Blow",
        billing_address: "1234 happy lane",
        billing_address2: "suit 234",
        billing_city:"Seattle",
        billing_state:"WA",
        billing_country:"USA",
        billing_postal_code:"98107"
      })

      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~SALE|AMOUNT~19.99|CUSTID~MMouse|BNAME~Joe Blow|BADDRESS~1234 happy lane|BADDRESS2~suit 234|BCITY~Seattle|BSTATE~WA|BCOUNTRY~USA|BZIP~98107|"
    end
  end

  it "can create and send a void transaction" do
    PayTrace::Transaction.void({transaction_id: "111"})
    assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Void|TRANXID~111|"
  end

  describe "forced sales" do
    it "can create a forced sale for a swiped credit card" do
      PayTrace::Transaction.swiped_forced_sale(amount: 19.99, swipe: "this is some fake swipe data", approval_code: 111)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Force|AMOUNT~19.99|SWIPE~this is some fake swipe data|APPROVAL~111|"
    end 

    it "can create a forced sale for a keyed-in credit card" do
      params = {
        amount: 19.98,
        card_number: 1234123412341234,
        expiration_month: 10,
        expiration_year: 24,
        approval_code: 123
      }
      PayTrace::Transaction.keyed_forced_sale(params)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Force|AMOUNT~19.98|CC~1234123412341234|EXPMNTH~10|EXPYR~24|APPROVAL~123|"
    end  

    it "can create a forced sale for a given customer ID" do
      PayTrace::Transaction.customer_id_forced_sale(amount: 19.99, customer_id: "MMouse", approval_code: 111)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Force|AMOUNT~19.99|CUSTID~MMouse|APPROVAL~111|"
    end  

     it "can create a forced sale for a given transaction ID" do
      PayTrace::Transaction.transaction_id_forced_sale(transaction_id: 1234, approval_code: 111)
      assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Force|TRANXID~1234|APPROVAL~111|"
    end  
  end

  it "can perform a capture transaction" do
    PayTrace::Transaction.capture(transaction_id: 1234)
    assert_last_request_equals "METHOD~PROCESSTRANX|TRANXTYPE~Capture|TRANXID~1234|"
  end
end
