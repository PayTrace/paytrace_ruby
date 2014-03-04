require File.expand_path(File.dirname(__FILE__) + '../../../test_helper.rb')
require 'paytrace/api/fields'


describe PayTrace::API do
  it "maps param list into paytrace url values" do 
    PayTrace::API.fields[:user_name].must_equal "UN"
    PayTrace::API.fields[:password].must_equal "PSWD"
    PayTrace::API.fields[:terms].must_equal "TERMS"
  end
end
