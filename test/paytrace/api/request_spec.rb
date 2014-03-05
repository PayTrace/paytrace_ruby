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
    t = PayTrace::Transaction.new(amount: "23.12", 
                                  credit_card: {
                                    card_number: "1234123412341234",
                                    expiration_year: 24,
                                    expiration_month: 10 },
                                 type: PayTrace::TransactionTypes::SALE)
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

end
