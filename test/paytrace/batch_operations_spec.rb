require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::BatchOperations do
  def base_url(method)
    "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~#{method}|"
  end

  before do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.reset_trace()
  end

  describe "exportSingle" do
    it "generates the correct request" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"
      result = PayTrace::BatchOperations.exportSingle()
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::BatchOperations::EXPORT_SINGLE_METHOD)
    end

    it "accepts an optional batch number" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"
      result = PayTrace::BatchOperations.exportSingle(batch_number: 12345)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::BatchOperations::EXPORT_SINGLE_METHOD) + "BATCHNUMBER~12345|"
    end
  end

  describe "exportMultiple" do
    it "generates the correct request" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"
      result = PayTrace::BatchOperations.exportMultiple(start_date: "03/01/2014", end_date: "06/01/2014")
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::BatchOperations::EXPORT_MULTIPLE_METHOD) +
        "SDATE~03/01/2014|EDATE~06/01/2014|"
    end
  end

  describe "exportDetails" do
    it "generates the correct request" do
      PayTrace::API::Gateway.next_response = "RESULT~Ok"
      result = PayTrace::BatchOperations.exportDetails(batch_number: 12346)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::BatchOperations::EXPORT_DETAILS_METHOD) + "BATCHNUMBER~12346|"
    end
  end
end