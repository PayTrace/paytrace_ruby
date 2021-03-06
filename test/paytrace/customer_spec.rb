require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Customer do
  before do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.next_response = "RESPONSE~ok|CUSTOMERID~12345|CUSTID~john_doe"
  end

  describe "export customers" do
    it "works" do
      PayTrace::API::Gateway.next_response = "CUSTOMERRECORD~CUSTID=741356+CUSTOMERID=741356+CC=************5454+EXPMNTH=12+EXPYR=17+SNAME=+SADDRESS=+SADDRESS2=+SCITY=+SCOUNTY=+SSTATE=+SZIP=+SCOUNTRY=US+BNAME=DUMMY1+BADDRESS=+BADDRESS2=+BCITY=+BSTATE=+BZIP=+BCOUNTRY=US+EMAIL=+PHONE=+FAX=+WHEN=2/7/2014 5:02:08 PM+USER=demo123+IP=131.191.89.5+DDA=123412341234+TR=051000017+hair_color=+|"
      records = PayTrace::Customer.export()

      assert_last_request_equals "METHOD~ExportCustomers|"
      records.count.must_equal 1
      records.must_be_instance_of Array
      records[0].must_be_instance_of Hash
      records[0].keys.count.must_equal 29
    end

    it "also exports inactive customers" do
      PayTrace::API::Gateway.next_response = "CUSTOMERRECORD~CUSTID=12345+BNAME=John Doe+LASTTRANX=01/01/2014+LASTCHECK=02/01/2014+WHEN=03/01/2014"
      records = PayTrace::Customer.export_inactive({days_inactive: 30})

      assert_last_request_equals "METHOD~ExportInactiveCustomers|DAYS~30|"
      records.count.must_equal 1
      records.must_be_instance_of Array
      records[0].must_be_instance_of Hash
      records[0].keys.count.must_equal 5
      records[0]['BNAME'].must_equal "John Doe"
    end
  end

  describe "create customer profile" do
    # first call path: create from credit card information
    it "can be created from credit card information" do
      params = {
        customer_id: "foo_bar",
        billing_name: "Foo Bar",
        card_number: "1234123412341234",
        expiration_month: 12,
        expiration_year: 2014
      }
      PayTrace::Customer.from_cc_info(params)
      assert_last_request_equals "METHOD~CreateCustomer|CUSTID~foo_bar|BNAME~Foo Bar|CC~1234123412341234|EXPMNTH~12|EXPYR~2014|"
    end

    # second call path: create from a transaction ID
    it "can be created from a transaction ID" do
      PayTrace::Customer.from_transaction_id({customer_id: "foo_bar", transaction_id: 12345678})
      assert_last_request_equals "METHOD~CreateCustomer|CUSTID~foo_bar|TRANXID~12345678|"
    end

    # all billing address fields are accepted
    it "accepts full billing address information" do
      params = {
        customer_id: "foo_bar",
        billing_name: "Foo Bar",
        billing_address: "1234 Main Street",
        billing_address2: "Apartment 1B",
        billing_city: "Shoreline",
        billing_state: "WA",
        billing_country: "USA",
        billing_postal_code: 98133,
        card_number: "1234123412341234",
        expiration_month: 12,
        expiration_year: 2014
      }

      PayTrace::Customer.from_cc_info(params)
      assert_last_request_equals "METHOD~CreateCustomer|CUSTID~foo_bar|BNAME~Foo Bar|BADDRESS~1234 Main Street|" + 
        "BADDRESS2~Apartment 1B|BCITY~Shoreline|BSTATE~WA|BZIP~98133|BCOUNTRY~USA|" +
        "CC~1234123412341234|EXPMNTH~12|EXPYR~2014|"
    end

    # you can include a shipping address, too
    it "accepts a shipping address" do
      params = {
        customer_id: "foo_bar",
        transaction_id: 12345678, 
        shipping_name: "Foo Bar",
        shipping_address: "1234 Main Street",
        shipping_address2: "Apartment 1B",
        shipping_city: "Shoreline",
        shipping_state: "WA",
        shipping_region: "Snohomish",
        shipping_country: "USA",
        shipping_postal_code: 98133
      }

      PayTrace::Customer.from_transaction_id(params)
      assert_last_request_equals "METHOD~CreateCustomer|CUSTID~foo_bar|TRANXID~12345678|SNAME~Foo Bar|SADDRESS~1234 Main Street|" + 
        "SADDRESS2~Apartment 1B|SCITY~Shoreline|SCOUNTY~Snohomish|SSTATE~WA|SZIP~98133|SCOUNTRY~USA|"
    end

    # there are additional fields (email, phone, discretionary data, etc.) that can be sent
    it "accepts extra customer information" do
      params = {
        customer_id: "foo_bar",
        transaction_id: 12345678,
        email: "support@paytrace.com",
        customer_phone: "123-555-1212",
        customer_fax: "456-555-1212",
        customer_password: "none_shall_pass",
        account_number: 123456789,
        routing_number: 12345678,
        discretionary_data: {hair_color: "red"}
      }

      PayTrace::Customer.from_transaction_id(params)
      assert_last_request_equals "METHOD~CreateCustomer|CUSTID~foo_bar|TRANXID~12345678|EMAIL~support@paytrace.com|" + 
        "PHONE~123-555-1212|FAX~456-555-1212|CUSTPSWD~none_shall_pass|DDA~123456789|TR~12345678|" +
        "hair_color~red|"
    end
  end

  describe "update customer profile" do
    it "accepts a billing address" do
      params = {
        customer_id: "john doe",
        new_customer_id: "joanie_doe", 
        billing_name: "Foo Bar",
        billing_address: "1234 Main Street",
        billing_address2: "Apartment 1B",
        billing_city: "Shoreline",
        billing_state: "WA",
        billing_country: "USA",
        billing_postal_code: 98133
      }

      PayTrace::Customer.update(params)

      assert_last_request_equals "METHOD~UpdateCustomer|CUSTID~john doe|" +
        "BNAME~Foo Bar|BADDRESS~1234 Main Street|" + 
        "BADDRESS2~Apartment 1B|BCITY~Shoreline|BSTATE~WA|BZIP~98133|BCOUNTRY~USA|NEWCUSTID~joanie_doe|" 
    end

    it "accepts a shipping address" do
      params = {
        customer_id: "john doe",
        new_customer_id: "joanie_doe", 
        shipping_name: "Foo Bar",
        shipping_address: "1234 Main Street",
        shipping_address2: "Apartment 1B",
        shipping_city: "Shoreline",
        shipping_state: "WA",
        shipping_region: "Snohomish",
        shipping_country: "USA",
        shipping_postal_code: 98133
      }

      PayTrace::Customer.update(params)

      assert_last_request_equals "METHOD~UpdateCustomer|CUSTID~john doe|" +
        "SNAME~Foo Bar|SADDRESS~1234 Main Street|SADDRESS2~Apartment 1B|SCITY~Shoreline|SCOUNTY~Snohomish|" +
        "SSTATE~WA|SZIP~98133|SCOUNTRY~USA|NEWCUSTID~joanie_doe|" 
    end

    it "accepts extra customer information" do
      params = {
        customer_id: "bar_foo",
        new_customer_id: "foo_bar",
        email: "support@paytrace.com",
        customer_phone: "123-555-1212",
        customer_fax: "456-555-1212",
        customer_password: "none_shall_pass",
        account_number: 123456789,
        routing_number: 12345678,
        discretionary_data: {hair_color: "red"}
      }

      PayTrace::Customer.update(params)

      assert_last_request_equals "METHOD~UpdateCustomer|CUSTID~bar_foo|" +
      "EMAIL~support@paytrace.com|PHONE~123-555-1212|FAX~456-555-1212|CUSTPSWD~none_shall_pass|DDA~123456789|" +
      "TR~12345678|NEWCUSTID~foo_bar|hair_color~red|"
    end
  end

  describe "delete customer profile" do
    it "works with a static class method" do
      PayTrace::Customer.delete("foob_barb")

      assert_last_request_equals "METHOD~DeleteCustomer|CUSTID~foob_barb|"
    end
  end
end