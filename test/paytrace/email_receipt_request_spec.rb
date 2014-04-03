require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::EmailReceiptRequest do
  it "correctly formats the request URL" do
    e = PayTrace::EmailReceiptRequest.new("support@paytrace.com", "FOO1234", false)
    r = e.set_request

    url = r.to_parms_string
    url.must_equal "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~EmailReceipt|TRANXID~FOO1234|EMAIL~support@paytrace.com|"
  end

  it "uses check id instead of transaction id if specified" do
    e = PayTrace::EmailReceiptRequest.new("support@paytrace.com", "CHECK2345", true)
    r = e.set_request

    url = r.to_parms_string
    url.must_equal "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~EmailReceipt|CHECKID~CHECK2345|EMAIL~support@paytrace.com|"
  end
end