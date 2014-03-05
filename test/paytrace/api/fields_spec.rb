require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/fields'


describe PayTrace::API do
  it "maps param list into paytrace url values" do 
    PayTrace::API.fields[:user_name].must_equal "UN"
    PayTrace::API.fields[:password].must_equal "PSWD"
    PayTrace::API.fields[:terms].must_equal "TERMS"
    PayTrace::API.fields[:card_number].must_equal "CC"
    PayTrace::API.fields[:expiration_year].must_equal "EXPYR"
    PayTrace::API.fields[:expiration_month].must_equal "EXPMNTH"
    PayTrace::API.fields[:method].must_equal "METHOD"
    PayTrace::API.fields[:transaction_type].must_equal "TRANXTYPE"
    PayTrace::API.fields[:amount].must_equal "AMOUNT"
  end
end
