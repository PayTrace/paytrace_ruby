require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::CheckTransaction do
  def base_url(method)
    "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~#{method}|"
  end

  before do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.reset_trace()
  end

  describe "sale transactions" do

    # UN, PSWD, TERMS, METHOD, CHECKTYPE, AMOUNT, DDA, TR
    it "should process a check payment via routing number/account number" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"
      params = {
        check_type: 'foo',
        amount: 17.29,
        account_number: 1234567,
        routing_number: 1234568
      }
      result = PayTrace::CheckTransaction.process_sale(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::PROCESS_SALE_METHOD) +
        "CHECKTYPE~foo|AMOUNT~17.29|DDA~1234567|TR~1234568|"
    end

    # UN, PSWD, TERMS, METHOD, CHECKTYPE, AMOUNT, CUSTID
    it "should process a check payment via customer id" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"
      params = {
        check_type: 'bar',
        amount: 17.28,
        customer_id: 'MMouse'
      }
      result = PayTrace::CheckTransaction.process_sale(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::PROCESS_SALE_METHOD) +
        "CHECKTYPE~bar|AMOUNT~17.28|CUSTID~MMouse|"
    end


    it "accepts billing and shipping information" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"

      ba = PayTrace::Address.new({
        name: "John Doe",
        street: "1234 Main Street",
        street2: "Apartment 1B",
        city: "Shoreline",
        state: "WA",
        country: "US",
        postal_code: "98133",
        address_type: :billing
      })

      sa = PayTrace::Address.new({
        name: "Jane Doe",
        street: "1235 Moon Street",
        street2: "Apartment 2C",
        city: "Shortline",
        state: "WA",
        country: "US",
        postal_code: "98134",
        address_type: :shipping
      })

      params = {
        check_type: 'baz',
        amount: 17.29,
        customer_id: 'DDuck',
        billing_address: ba,
        shipping_address: sa
      }

      result = PayTrace::CheckTransaction.process_sale(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::PROCESS_SALE_METHOD) +
        "CHECKTYPE~baz|AMOUNT~17.29|CUSTID~DDuck|BNAME~John Doe|BADDRESS~1234 Main Street|BADDRESS2~Apartment 1B|BCITY~Shoreline|BSTATE~WA|BZIP~98133|BCOUNTRY~US|SNAME~Jane Doe|SADDRESS~1235 Moon Street|SADDRESS2~Apartment 2C|SCITY~Shortline|SSTATE~WA|SZIP~98134|SCOUNTRY~US|"
    end


    it "accepts email, invoice, description, tax amount, and customer reference id" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"

      params = {
        email: 'foo@bar.com',
        description: 'You bought something with a check, yo!',
        invoice: '12345',
        amount: 17.27,
        customer_id: 'YosemiteSam',
        tax_amount: 2.11,
        customer_reference_id: '1234AB'
      }
      result = PayTrace::CheckTransaction.process_sale(params)

      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::PROCESS_SALE_METHOD) +
        "AMOUNT~17.27|CUSTID~YosemiteSam|EMAIL~foo@bar.com|INVOICE~12345|DESCRIPTION~You bought something with a check, yo!|TAX~2.11|CUSTREF~1234AB|"
    end

    it "accepts discretionary data" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"

      params = {
        check_type: 'foo',
        amount: 17.29,
        account_number: 1234567,
        routing_number: 1234568,
        discretionary_data: {hair_color: :red}
      }
      result = PayTrace::CheckTransaction.process_sale(params)

      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::PROCESS_SALE_METHOD) +
        "CHECKTYPE~foo|AMOUNT~17.29|DDA~1234567|TR~1234568|hair_color~red|"
    end
  end

  # hold transactions are just sale transactions with a CheckType of "Hold" -- don't need to re-test
  describe "hold transactions" do
    it "accepts a routing number/account number hold request" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"
      params = {
        check_type: 'foo',
        amount: 17.29,
        account_number: 1234567,
        routing_number: 1234568,
        discretionary_data: {hair_color: :red}
      }
      result = PayTrace::CheckTransaction.process_hold(params)

      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::PROCESS_SALE_METHOD) +
        "AMOUNT~17.29|DDA~1234567|TR~1234568|CHECKTYPE~Hold|hair_color~red|"
    end

    describe "refund transactions" do
      it "accepts a check ID" do
        PayTrace::API::Gateway.next_response = "RESULT~Ok"
        params = {
          check_type: 'foo',
          check_id: 12345678
        }
        result = PayTrace::CheckTransaction.process_refund(params)

        PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::PROCESS_SALE_METHOD) +
          "CHECKID~12345678|CHECKTYPE~Refund|"
      end
    end

    describe "manage a check" do
      it "accepts check id" do
        PayTrace::API::Gateway.next_response = "RESULT~Ok"
        params = {
          check_type: 'Hold',
          check_id: 12345678
        }
        result = PayTrace::CheckTransaction.manage_check(params)

        PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::CheckTransaction::MANAGE_CHECK_METHOD) +
          "CHECKTYPE~Hold|CHECKID~12345678|"
      end
    end
  end
end