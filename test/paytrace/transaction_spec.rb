require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Transaction do
  before do
    @response = mock()
    PayTrace::API::Gateway.any_instance.expects(:send_request).returns(@response)
  end

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
    t.response.must_equal @response
  end

  it "can run a transaction for a customer" do
    t = PayTrace::Transaction.sale(
      amount: "1.00",
      customer_id: "123456"
    )

    t.amount.must_equal "1.00"
    t.type.must_equal PayTrace::TransactionTypes::SALE
    t.customer.customer_id.must_equal "123456"
    t.credit_card.must_be_nil

    t.response.must_equal @response

  end

end
