require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Transaction do
  it "can charge sales to a credit card" do
    t = PayTrace::Transaction.sale(
      amount: "1242.32",
      credit_card: {
        card_number: "1234123412341234",
        expiration_month: 10,
        expiration_year:  24
    })
    t.amount.must_equal "1242.32"
    t.credit_card.card_number.must_equal "1234123412341234"

  end
end
