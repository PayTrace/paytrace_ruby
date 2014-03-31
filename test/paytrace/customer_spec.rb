require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

def mock_send(response = nil)
  # we expect the static methods to create a new request -- make this a real
  # request so we can get to the final URL if needed
  request = PayTrace::API::Request.new
  PayTrace::API::Request.expects(:new).returns(request)

  # gateway and response can be full mocks, unless we want to pass in a response...
  gateway = mock()
  response ||= mock()
  PayTrace::API::Gateway.expects(:new).returns(gateway)
  gateway.expects(:send_request).with(request).returns(response)

  # finally, the static methods call the private #initialize (:new) with the mock response
  PayTrace::Customer.expects(:new).with(response)

  return request, response
end

def base_url
  "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|METHOD~CreateCustomer|"
end

describe PayTrace::Customer do
  describe "create customer" do
    # first call path: create from credit card information
    it "can be created from credit card information" do
      credit_card = PayTrace::CreditCard.new({card_number: "1234123412341234", expiration_month: 12, expiration_year: 2014})
      billing_addr = PayTrace::Address.new({name: "Foo Bar", address_type: :billing})

      request, response = mock_send()
      PayTrace::Customer.from_cc_info("foo_bar", credit_card, billing_addr)
      
      url = request.to_parms_string
      url.must_equal base_url + "CUSTID~foo_bar|BNAME~Foo Bar|CC~1234123412341234|EXPMNTH~12|EXPYR~2014|"
    end

    # second call path: create from a transaction ID
    it "can be created from a transaction ID" do
      request, response = mock_send()
      PayTrace::Customer.from_transaction_id("foo_bar", 12345678)

      url = request.to_parms_string
      url.must_equal base_url + "CUSTID~foo_bar|TRANXID~12345678|"
    end

    # all billing address fields are accepted
    it "accepts full billing address information" do
      credit_card = PayTrace::CreditCard.new({card_number: "1234123412341234", expiration_month: 12, expiration_year: 2014})
      billing_addr = PayTrace::Address.new({
        name: "Foo Bar",
        street: "1234 Main Street",
        street2: "Apartment 1B",
        city: "Shoreline",
        state: "WA",
        country: "USA",
        postal_code: 98133,
        address_type: :billing
        })

      request, response = mock_send()
      PayTrace::Customer.from_cc_info("foo_bar", credit_card, billing_addr)
      
      url = request.to_parms_string
      url.must_equal base_url + "CUSTID~foo_bar|BNAME~Foo Bar|BADDRESS~1234 Main Street|" + 
        "BADDRESS2~Apartment 1B|BCITY~Shoreline|BSTATE~WA|BZIP~98133|BCOUNTRY~USA|" +
        "CC~1234123412341234|EXPMNTH~12|EXPYR~2014|"
    end

    # you can include a shipping address, too
    it "accepts a shipping address" do
      shipping_addr = PayTrace::Address.new({
        name: "Foo Bar",
        street: "1234 Main Street",
        street2: "Apartment 1B",
        city: "Shoreline",
        state: "WA",
        region: "Snohomish",
        country: "USA",
        postal_code: 98133,
        address_type: :shipping
        })

      request, response = mock_send()
      PayTrace::Customer.from_transaction_id("foo_bar", 12345678, nil, shipping_addr)
      url = request.to_parms_string
      url.must_equal base_url + "CUSTID~foo_bar|TRANXID~12345678|SNAME~Foo Bar|SADDRESS~1234 Main Street|" + 
        "SADDRESS2~Apartment 1B|SCITY~Shoreline|SCOUNTY~Snohomish|SSTATE~WA|SZIP~98133|SCOUNTRY~USA|"
    end

    # special case: when creating from transaction ID, the billing name is ignored (no clue why, but it's in the API)
    it "ignores the billing address name if using a transaction id" do
      billing_addr = PayTrace::Address.new({
        name: "Foo Bar",
        street: "1234 Main Street",
        street2: "Apartment 1B",
        city: "Shoreline",
        state: "WA",
        region: "region",
        country: "USA",
        postal_code: 98133,
        address_type: :billing
        })

      request, response = mock_send()
      PayTrace::Customer.from_transaction_id("foo_bar", 12345678, billing_addr)

      url = request.to_parms_string
      url.must_equal base_url + "CUSTID~foo_bar|TRANXID~12345678|BADDRESS~1234 Main Street|" + 
        "BADDRESS2~Apartment 1B|BCITY~Shoreline|BSTATE~WA|BZIP~98133|BCOUNTRY~USA|"
    end

    # there are additional fields (email, phone, discretionary data, etc.) that can be sent
    it "accepts extra customer information" do
      extra_customer_info = {
        email: "support@paytrace.com",
        phone: "123-555-1212",
        fax: "456-555-1212",
        customer_password: "none_shall_pass",
        account_number: 123456789,
        routing_number: 12345678,
        discretionary_data: "discretionary_data"
      }

      request, response = mock_send()
      PayTrace::Customer.from_transaction_id("foo_bar", 12345678, nil, nil, extra_customer_info)

      url = request.to_parms_string
      url.must_equal base_url + "CUSTID~foo_bar|TRANXID~12345678|EMAIL~support@paytrace.com|" + 
        "PHONE~123-555-1212|FAX~456-555-1212|CUSTPSWD~none_shall_pass|DDA~123456789|TR~12345678|" +
        "DISCRETIONARY DATA~discretionary_data|"
    end
  end
end