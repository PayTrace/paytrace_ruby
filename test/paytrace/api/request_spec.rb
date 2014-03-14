require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/request'

describe PayTrace::API::Request do
  before do
    PayTrace.configure do |config|
      config.user_name = "test"
      config.password = "test"
    end
  end

  it "sets the user name, password, and terms parameters from the configuration file" do
    #override to validate
    PayTrace.configure do |config|
      config.user_name = "request_test"
      config.password = "request_password"
    end

    r = PayTrace::API::Request.new
    r.params[:user_name].must_equal "request_test"
    r.params[:password].must_equal "request_password"
    r.params[:terms].must_equal "Y"
    to_url = r.to_parms_string
    to_url.must_equal "UN~request_test|PSWD~request_password|TERMS~Y|"
  end

  it "can add a transaction to its param list" do
    t = PayTrace::Transaction.new({amount: "23.12",
                                  credit_card: PayTrace::CreditCard.new({
                                    card_number: "1234123412341234",
                                    expiration_year: 24,
                                    expiration_month: 10 }),
                                 type: PayTrace::TransactionTypes::SALE})
    r = PayTrace::API::Request.new(transaction: t)

    r.params[:card_number].must_equal "1234123412341234"
    r.params[:expiration_month].must_equal 10
    r.params[:expiration_year].must_equal 24
    r.params[:transaction_type].must_equal "SALE"
    r.params[:method].must_equal "PROCESSTRANX"
    r.params[:amount].must_equal "23.12"

    url = r.to_parms_string
    url.must_equal "UN~test|PSWD~test|TERMS~Y|CC~1234123412341234|EXPMNTH~10|EXPYR~24|TRANXTYPE~SALE|METHOD~PROCESSTRANX|AMOUNT~23.12|"
  end

  it "can use a customer id for processing the transaction" do
    t = PayTrace::Transaction.new({amount: "12.34",
                                    customer: PayTrace::Customer.new(customer_id: "1234"),
                                    type: PayTrace::TransactionTypes::SALE
                                    }
                                 )
    r = PayTrace::API::Request.new(transaction: t)
    r.params[:customer_id].must_equal "1234"
    r.params[:amount].must_equal "12.34"

    url = r.to_parms_string

    #Make sure it puts in values we expect
    url.must_match  /\|CUSTID~1234\|/
    url.must_match /\|AMOUNT~12.34\|/
    url.must_match /\|METHOD~PROCESSTRANX\|/
    url.must_match /\|TRANXTYPE~SALE\|/
  end

  it "can include a billing address" do
    t = PayTrace::Transaction.new(
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
    )
    r = PayTrace::API::Request.new(transaction: t)

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
    t = PayTrace::Transaction.new(
        optional: {
          email:"it@paytrace.com",
          description:"This is a test",
          tax_amount: "1.00",
          return_clr: "Y",
          enable_partial_authentication:"Y",
          discretionary_data:"This is some data that is discretionary",
          custom_dba:"NewName"
        }
    )

    r = PayTrace::API::Request.new(transaction: t)

    url = r.to_parms_string

    url.must_match /\|DESCRIPTION~This is a test\|/
    url.must_match /\|TAX~1.00\|/
    url.must_match /\|EMAIL~it@paytrace.com\|/
    url.must_match /\|RETURNCLR~Y\|/
    url.must_match /\|ENABLEPARTIALAUTH~Y\|/
    url.must_match /\|DISCRETIONARY DATA~This is some data that is discretionary\|/
    url.must_match /\|CUSTOMDBA~NewName\|/
  end

  it "can do a swipe transaction" do
    cc =  PayTrace::CreditCard.new( {
            swipe: '%B4055010000000005^J/SCOTT^1212101001020001000000701000000?;4055010000000005=12121010010270100001?'
          })
        t = PayTrace::Transaction.new(
        amount: '1.00',
        credit_card:cc
    )

    r = PayTrace::API::Request.new(transaction: t)
    url = r.to_parms_string

    url.must_match /\|AMOUNT~1.00\|/
    url.must_match /\|SWIPE~%B4055010000000005/


  end
end
