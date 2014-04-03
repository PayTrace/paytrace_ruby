require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::RecurringTransaction do
  def base_url(method)
    "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~#{method}|"
  end
  
  describe "create recurrence" do
    before do
      PayTrace::API::Gateway.debug = true
      PayTrace::API::Gateway.next_response = "RESPONSE~ok|RECURID~12345|"
    end

    it "works" do
      params = {
        customer_id: "foo_bar",
        recur_frequency: "3",
        recur_start: "4/22/2014",
        recur_count: 999,
        amount: 9.99,
        transaction_type: "sale",
        description: "Recurring transaction",
        recur_receipt: "Y",
        recur_type: "A"
      }

      recur_id = PayTrace::RecurringTransaction.create(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::RecurringTransaction::CREATE_METHOD) + 
        "CUSTID~foo_bar|FREQUENCY~3|START~4/22/2014|TOTALCOUNT~999|AMOUNT~9.99|TRANXTYPE~sale|DESCRIPTION~Recurring transaction|CUSTRECEIPT~Y|RECURTYPE~A|"

      recur_id.must_equal "12345"
    end
  end

  describe "update recurrence" do
    before do
      PayTrace::API::Gateway.debug = true
      PayTrace::API::Gateway.next_response = "RESPONSE~ok|RECURID~12345|"
    end

    it "works" do
      params = {
        recur_id: 12345,
        customer_id: "foo_bar",
        recur_frequency: "3",
        recur_start: "4/22/2014",
        recur_count: 999,
        amount: 9.99,
        transaction_type: "sale",
        description: "Recurring transaction",
        recur_receipt: "Y"
      }

      recur_id = PayTrace::RecurringTransaction.update(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::RecurringTransaction::UPDATE_METHOD) + 
        "RECURID~12345|CUSTID~foo_bar|FREQUENCY~3|START~4/22/2014|TOTALCOUNT~999|AMOUNT~9.99|TRANXTYPE~sale|" +
        "DESCRIPTION~Recurring transaction|CUSTRECEIPT~Y|"

      recur_id.must_equal "12345"
    end

    it "accepts a recur type" do
      params = {
        recur_id: 12345,
        customer_id: "foo_bar",
        recur_frequency: "3",
        recur_start: "4/22/2014",
        recur_count: 999,
        amount: 9.99,
        transaction_type: "sale",
        description: "Recurring transaction",
        recur_receipt: "Y",
        recur_type: "A"
      }

      recur_id = PayTrace::RecurringTransaction.update(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::RecurringTransaction::UPDATE_METHOD) + 
        "RECURID~12345|CUSTID~foo_bar|FREQUENCY~3|START~4/22/2014|TOTALCOUNT~999|AMOUNT~9.99|TRANXTYPE~sale|" +
        "DESCRIPTION~Recurring transaction|CUSTRECEIPT~Y|RECURTYPE~A|"

      recur_id.must_equal "12345"
    end
  end

  describe "delete recurrence" do
    before do
      PayTrace::API::Gateway.debug = true
      PayTrace::API::Gateway.next_response = "RESPONSE~ok|RECURID~12345|"
    end

    it "works with a recur ID" do
      params = {
        recur_id: 12345
      }

      recur_id = PayTrace::RecurringTransaction.delete(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::RecurringTransaction::DELETE_METHOD) + 
        "RECURID~12345|"
      
      recur_id.must_equal "12345"
    end

    it "works with a customer ID" do
      params = {
        customer_id: "foo_bar"
      }

      recur_id = PayTrace::RecurringTransaction.delete(params)
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::RecurringTransaction::DELETE_METHOD) + 
        "CUSTID~foo_bar|"
      
      recur_id.must_equal "12345"
    end
  end

  describe "export single approved recurrence" do
    before do
      PayTrace::API::Gateway.debug = true
      PayTrace::API::Gateway.next_response = "RESPONSE~ok|RECURID~12345|"
    end

    it "works" do
      PayTrace::RecurringTransaction.export_approved({customer_id: "john_doe"})
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::RecurringTransaction::EXPORT_APPROVED_METHOD) + 
        "CUSTID~john_doe|"
    end
  end
  
  describe "export scheduled recurrences" do
    before do
      PayTrace::API::Gateway.debug = true
      PayTrace::API::Gateway.next_response = "RECURRINGPAYMENT~RECURID=72553+AMOUNT=9.99+CUSTID=john_doe+NEXT=4/22/2016+TOTALCOUNT=999+CURRENTCOUNT=0+REPEAT=0+DESCRIPTION=Recurring transaction+"
    end

    it "works" do
      exported = PayTrace::RecurringTransaction.export_scheduled({customer_id: "john_doe"})
      PayTrace::API::Gateway.last_request.must_equal base_url(PayTrace::RecurringTransaction::EXPORT_SCHEDULED_METHOD) + 
        "CUSTID~john_doe|"

      exported.must_be_instance_of PayTrace::RecurringTransaction
    end
  end
end