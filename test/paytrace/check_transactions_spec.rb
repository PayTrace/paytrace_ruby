require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::CheckTransaction do
  def base_url(method)
    "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~#{method}|"
  end

  before do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.reset_trace()
  end

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

  it "accepts billing and shipping information"
  it "accepts email, invoice, description, tax amount, and customer reference id"
  it "accepts discretionary data"
end