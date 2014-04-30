require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Transaction do
  def base_url
    "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|"
  end

  before do
    PayTrace::API::Gateway.debug = true
    PayTrace::API::Gateway.reset_trace()
  end

  it "exports transaction(s)" do
    PayTrace::API::Gateway.next_response = "TRANSACTIONRECORD~TRANXID=1143"
    records = PayTrace::Transaction.export({transaction_id: 1143})
    records.must_be_instance_of Array
    records.count.must_equal 1
    records[0].must_be_instance_of Hash
    records[0]["TRANXID"].must_equal "1143"
  end

  it "successfully attaches base-64 encoded signatures to transactions" do
    PayTrace::API::Gateway.next_response = "RESPONSE~172. The signature image was successfully attached to Transaction ID 13192003.|"
    result = PayTrace::Transaction.attach_signature({transaction_id: 13192003, image_data: "foo", image_type: "png"})
    result.has_errors?.must_equal false
  end

  it "successfully attaches image files to transactions" do
    PayTrace::API::Gateway.next_response = "RESPONSE~172. The signature image was successfully attached to Transaction ID 13192003.|"
    result = PayTrace::Transaction.attach_signature({transaction_id: 13192003, image_file: __FILE__, image_type: "png"})
    result.has_errors?.must_equal false
  end

  it "calculates shipping costs" do
    PayTrace::API::Gateway.next_response = "SHIPPINGRECORD~SHIPPINGCOMPANY=USPS+SHIPPINGMETHOD=STANDARD POST+SHIPPINGRATE=12.72|"
    params = {
      #UN, PSWD, TERMS, METHOD, SOURCEZIP, SOURCESTATE, SZIP, WEIGHT, SHIPPERS, SSTATE
      source_zip: 98133,
      source_state: "WA", 
      shipping_postal_code: 94947,
      shipping_weight: 5.1,
      shippers: "UPS,USPS,FEDEX",
      shipping_state: "CA",
      shipping_country: "US"
    }
    result = PayTrace::Transaction.calculate_shipping(params)
    result[0]['SHIPPINGCOMPANY'].must_equal "USPS"
  end

  it "can adjust a transaction" do
    PayTrace::API::Gateway.next_response = "SHIPPINGRECORD~SHIPPINGCOMPANY=USPS+SHIPPINGMETHOD=STANDARD POST+SHIPPINGRATE=12.72|"
    params = {
      transaction_id: 1234,
      amount: 9.87
    }
    result = PayTrace::Transaction.adjust_amount(params)
    PayTrace::API::Gateway.last_request.must_equal base_url + "METHOD~AdjustAmount|TRANXID~1234|AMOUNT~9.87|"
  end

  it "can settle a transaction by recurrence ID" do
    PayTrace::API::Gateway.next_response = "SHIPPINGRECORD~SHIPPINGCOMPANY=USPS+SHIPPINGMETHOD=STANDARD POST+SHIPPINGRATE=12.72|"
    params = {
      # UN, PSWD, TERMS, METHOD, RECURID
      recur_id: 12345
    }
    result = PayTrace::Transaction.settle_transaction(params)
    PayTrace::API::Gateway.last_request.must_equal base_url + "METHOD~SettleTranx|RECURID~12345|"
  end

  it "can settle a transaction by customer ID" do
    PayTrace::API::Gateway.next_response = "SHIPPINGRECORD~SHIPPINGCOMPANY=USPS+SHIPPINGMETHOD=STANDARD POST+SHIPPINGRATE=12.72|"
    params = {
      # UN, PSWD, TERMS, METHOD, RECURID
      customer_id: 12346
    }
    result = PayTrace::Transaction.settle_transaction(params)
    PayTrace::API::Gateway.last_request.must_equal base_url + "METHOD~SettleTranx|CUSTID~12346|"
  end

  describe "create sales transactions" do
    before do
      @response = mock()
      PayTrace::API::Gateway.any_instance.expects(:send_request).returns(@response)
    end
    it "can create a Payment Authorization" do
      t = PayTrace::Transaction.authorization(
          { amount:"1242.32",
          credit_card: {
            card_number:"1234123412341234",
            expiration_month:10,
            expiration_year:24
          }
        }
      )


      #Transaction is properly configured
      t.amount.must_equal "1242.32"
      t.type.must_equal PayTrace::TransactionTypes::Authorization

      #Sets up a card
      t.credit_card.card_number.must_equal "1234123412341234"
      t.credit_card.expiration_month.must_equal 10
      t.credit_card.expiration_year.must_equal 24
    end

    it "can charge sales to a credit card" do
      t = PayTrace::Transaction.sale(
          {amount: "1242.32",
          credit_card: {
            card_number: "1234123412341234",
            expiration_month: 10,
            expiration_year:  24
          }
        })

      #Transaction is properly configured
      t.amount.must_equal "1242.32"
      t.type.must_equal PayTrace::TransactionTypes::SALE

      #Sets up a card
      t.credit_card.card_number.must_equal "1234123412341234"
      t.credit_card.expiration_month.must_equal 10
      t.credit_card.expiration_year.must_equal 24
      t.response.must_equal @response
    end

    it "can run a transaction for a customer" do
      t = PayTrace::Transaction.sale(
          {amount: "1.00",
           customer: 123456}
      )

      t.amount.must_equal "1.00"
      t.type.must_equal PayTrace::TransactionTypes::SALE
      t.customer.must_equal 123456
      t.credit_card.must_be_nil
      t.response.must_equal @response

    end

    it "can run a cash advance" do

      args = {
        amount:"1.00",
        cc_last_4:"1234",
        id_number:"12345",
        id_expiration:"12/29/2020",
        billing_address: {
          street: "1234 happy lane",
          street2: "apt #1",
          city: "Seattle",
          state: "WA",
          postal_code:"98107",
          country:"US"
        },
        credit_card: {
            swipe:'%B5454545454545454^J/SCOTT^2612101001020001000000701000000?;5454545454545454=26121010010270100001?'
        }
      }
      t = PayTrace::Transaction.cash_advance(args)

      t.amount.must_equal "1.00"
      t.type.must_equal PayTrace::TransactionTypes::SALE
      t.credit_card.swipe.must_equal '%B5454545454545454^J/SCOTT^2612101001020001000000701000000?;5454545454545454=26121010010270100001?'
      t.optional_fields[:cc_last_4].must_equal "1234"
      t.optional_fields[:id_expiration].must_equal "12/29/2020"
      t.optional_fields[:id_number].must_equal "12345"

      t.billing_address.street.must_equal "1234 happy lane"
      t.response.must_equal @response

    end


  end
  describe "adding address info" do
    it "can take a shipping address" do
      t = PayTrace::Transaction.new({
              optional:{
              shipping_address: {
                  name: "Bob Smith",
                  street: "1234 happy lane",
                  street2: "suit 234",
                  city:"Seattle",
                  state:"WA",
                  country:"USA",
                  postal_code:"98107"
              }
            }
                                    })
      s = t.shipping_address
      s.name.must_equal "Bob Smith"
      s.street.must_equal "1234 happy lane"
      s.street2.must_equal "suit 234"
      s.city.must_equal "Seattle"
      s.state.must_equal "WA"
      s.country.must_equal "USA"
      s.postal_code.must_equal "98107"

    end
    it "can take a billing address" do
      t = PayTrace::Transaction.new({
                optional: {
                billing_address: {
                street: "1234 happy lane",
                street2: "suit 234",
                city:"Seattle",
                state:"WA",
                country:"USA",
                postal_code:"98107"
              }
            }
                                    })
        b = t.billing_address
        b.street.must_equal "1234 happy lane"
        b.street2.must_equal "suit 234"
        b.city.must_equal "Seattle"
        b.state.must_equal "WA"
        b.country.must_equal "USA"
        b.postal_code.must_equal "98107"
    end

    it "will return the same address if set to billing shipping same address" do
      address = {
        street: "1234 happy lane",
        street2: "suit 234",
        city:"Seattle",
        state:"WA",
        country:"USA",
        postal_code:"98107"
      }

      t = PayTrace::Transaction.new({
          optional: { billing_address: address
          } })
      t.set_shipping_same_as_billing

      t.shipping_address.must_equal t.billing_address
    end

  end

  it "can be set to void a transaction" do
    t = PayTrace::Transaction.new({optional:{transaction_id:"11"}})
  end

  it "can create and send a void transaction" do
    @response = mock()
    PayTrace::API::Gateway.any_instance.expects(:send_request).returns(@response)

    t = PayTrace::Transaction.void("111")
    t.optional_fields[:transaction_id].must_equal "111"
    t.type.must_equal PayTrace::TransactionTypes::Void
  end

  it "can create a forced sale" do
    @response = mock()
    PayTrace::API::Gateway.any_instance.expects(:send_request).returns(@response)
    t = PayTrace::Transaction.forced_sale("111",{})

    t.optional_fields[:approval_code].must_equal "111"
    t.type.must_equal PayTrace::TransactionTypes::ForcedSale




  end


  it "can add a transaction to its param list" do
    t = PayTrace::Transaction.new({amount: "23.12",
                                  credit_card: PayTrace::CreditCard.new({
                                    card_number: "1234123412341234",
                                    expiration_year: 24,
                                    expiration_month: 10 }),
                                 type: PayTrace::TransactionTypes::SALE})
    r = PayTrace::API::Request.new
    t.set_request(r)

    r.params[:card_number].must_equal ["1234123412341234"]
    r.params[:expiration_month].must_equal [10]
    r.params[:expiration_year].must_equal [24]
    r.params[:transaction_type].must_equal ["SALE"]
    r.params[:method].must_equal ["PROCESSTRANX"]
    r.params[:amount].must_equal ["23.12"]

    url = r.to_parms_string
    url.must_equal "UN~#{PayTrace.configuration.user_name}|PSWD~#{PayTrace.configuration.password}|TERMS~Y|CC~1234123412341234|EXPMNTH~10|EXPYR~24|TRANXTYPE~SALE|METHOD~PROCESSTRANX|AMOUNT~23.12|"
  end

  it "can use a customer id for processing the transaction" do
    t = PayTrace::Transaction.new({amount: "12.34",
                                    customer: 1234,
                                    type: PayTrace::TransactionTypes::SALE
                                    }
                                 )
    r = PayTrace::API::Request.new
    t.set_request(r)

    r.params[:customer_id].must_equal [1234]
    r.params[:amount].must_equal ["12.34"]

    url = r.to_parms_string

    #Make sure it puts in values we expect
    url.must_match  /\|CUSTID~1234\|/
    url.must_match /\|AMOUNT~12.34\|/
    url.must_match /\|METHOD~PROCESSTRANX\|/
    url.must_match /\|TRANXTYPE~SALE\|/
  end

  it "can include a billing address" do
    t = PayTrace::Transaction.new({
          optional:{
            billing_address:{
              name:"John Doe",
              street:"1234 happy lane",
              street2:"apt#2",
              city:"Seattle",
              state:"WA",
              country: "US",
              postal_code:"98107"
            }
          }
                                  })

    t.shipping_address.must_be_nil

    r = PayTrace::API::Request.new
    t.set_request(r)

    url = r.to_parms_string

    #Make sure it puts in values we expect
    url.must_match /\|BNAME~John Doe\|/
    url.must_match /\|BADDRESS~1234 happy lane\|/
    url.must_match /\|BADDRESS2~apt#2\|/
    url.must_match /\|BCITY~Seattle\|/
    url.must_match /\|BSTATE~WA\|/
    url.must_match /\|BSTATE~WA\|/
    url.must_match /\|BCOUNTRY~US\|/

  end

  it "can include misc fields as well" do
    t = PayTrace::Transaction.new({
        optional: {
          email:"it@paytrace.com",
          description:"This is a test",
          tax_amount: "1.00",
          return_clr: "Y",
          enable_partial_authentication:"Y",
          custom_dba:"NewName"
        },
        discretionary_data: {hair_color: "red"}
                                  })

    r = PayTrace::API::Request.new
    t.set_request(r)

    url = r.to_parms_string

    url.must_match /\|DESCRIPTION~This is a test\|/
    url.must_match /\|TAX~1.00\|/
    url.must_match /\|EMAIL~it@paytrace.com\|/
    url.must_match /\|RETURNCLR~Y\|/
    url.must_match /\|ENABLEPARTIALAUTH~Y\|/
    url.must_match /\|hair_color~red\|/
    url.must_match /\|CUSTOMDBA~NewName\|/
  end

  it "can do a swipe transaction" do
    cc =  PayTrace::CreditCard.new( {
            swipe: '%B4055010000000005^J/SCOTT^1212101001020001000000701000000?;4055010000000005=12121010010270100001?'
          })
        t = PayTrace::Transaction.new({
        amount: '1.00',
        credit_card:cc
                                      })

    r = PayTrace::API::Request.new
    t.set_request(r)

    url = r.to_parms_string

    url.must_match /\|AMOUNT~1.00\|/
    url.must_match /\|SWIPE~%B4055010000000005/


  end

  it "can do a reference sales request " do

    t = PayTrace::Transaction.new({
        amount: '1.00',
        optional:{transaction_id: '1234'}
                                  })

    r = PayTrace::API::Request.new
    t.set_request(r)

    url = r.to_parms_string

    url.must_match /\|AMOUNT~1.00\|/
    url.must_match /\|TRANXID~1234|/
  end

  it "can create an approval code call" do
    t = PayTrace::Transaction.new({amount: "23.12",
                                   credit_card: PayTrace::CreditCard.new({
                                                                             card_number: "1234123412341234",
                                                                             expiration_year: 24,
                                                                             expiration_month: 10 }),
                                   type: PayTrace::TransactionTypes::ForcedSale,
                                   optional:{approval_code:'1234'}
                                  })

    r = PayTrace::API::Request.new
    t.set_request(r)

    url = r.to_parms_string

    url.must_match /\|APPROVAL~1234\|/
    url.must_match  /\|TRANXTYPE~Force\|/

  end

  it "can create a new cash_advance sale" do
    cc =  PayTrace::CreditCard.new( {
                                        swipe: '%B4055010000000005^J/SCOTT^1212101001020001000000701000000?;4055010000000005=12121010010270100001?'
                                    })

    optional = {
        billing_address:{
            name:"John Doe",
            street:"1234 happy lane",
            street2:"apt#2",
            city:"Seattle",
            state:"WA",
            country: "US",
            postal_code:"98107"
        },
        id_number:  "1234",
        id_expiration:"12/20/2020",
        cc_last_4: "1234",
        cash_advance: "Y"


    }
    t = PayTrace::Transaction.new({
        amount: '1.00',
        credit_card:cc,
        type: PayTrace::TransactionTypes::SALE,
        optional:optional
                                  })

    r = PayTrace::API::Request.new
    t.set_request(r)

    url = r.to_parms_string

    url.must_match /\|AMOUNT~1.00\|/
    url.must_match /\|SWIPE~%B4055010000000005/
    url.must_match /\|CASHADVANCE~Y\|/
    url.must_match /\|PHOTOID~1234\|/
    url.must_match /\|LAST4~1234\|/
    url.must_match /\|BADDRESS~1234 happy lane\|/




  end

end
