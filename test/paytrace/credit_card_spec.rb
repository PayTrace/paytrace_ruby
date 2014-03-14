require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::CreditCard do
  it "can be initialized with nothing" do
    cc = PayTrace::CreditCard.new
    cc.card_number.must_be_nil
  end
  it "can be initialized from a card number and expiration date" do
    cc = PayTrace::CreditCard.new(:card_number => "5454545454545454", :expiration_month => 10, :expiration_year => 24)
    cc.card_number.must_equal "5454545454545454"
    cc.expiration_month.must_equal 10
    cc.expiration_year.must_equal 24
  end

  it "can be initialized from a hash" do
    cc =  {credit_card: {
        card_number: "1234123412341234",
        expiration_month: 10,
        expiration_year:  24
    }}

   cc = PayTrace::CreditCard.new(cc[:credit_card])
    cc.card_number.must_equal "1234123412341234"

  end
end
