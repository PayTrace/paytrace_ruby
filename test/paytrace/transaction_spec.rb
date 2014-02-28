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

    #Transaction is properly configured
    t.amount.must_equal "1242.32"
    t.type.must_equal PayTrace::TransactionTypes::SALE

    #Sets up a card
    t.credit_card.card_number.must_equal "1234123412341234"
    t.credit_card.expiration_month.must_equal 10
    t.credit_card.expiration_year.must_equal 24

  end
end
