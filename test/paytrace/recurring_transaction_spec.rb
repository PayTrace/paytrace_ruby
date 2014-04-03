require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

def base_url(method)
  "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~#{method}|"
end

describe PayTrace::RecurringTransaction do
  describe "create recurrence" do
    before do
      PayTrace::API::Gateway.debug = true
      PayTrace::API::Gateway.next_response = "RESPONSE~ok|RECURID~12345|"
    end

    it "works" do
      # UN, PSWD, TERMS, METHOD, CUSTID, FREQUENCY, START, TOTALCOUNT, AMOUNT, TRANXTYPE
      # DESCRIPTION, CUSTRECEIPT, RECURTYPE

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
  # describe "export single recurrence"
  # describe "bulk update recurrences"
end