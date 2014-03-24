require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Transaction do
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
           customer_id: "123456"}
      )

      t.amount.must_equal "1.00"
      t.type.must_equal PayTrace::TransactionTypes::SALE
      t.customer.customer_id.must_equal "123456"
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
      t = PayTrace::Transaction.new(
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
        )
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
      t = PayTrace::Transaction.new(
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
        )
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

      t = PayTrace::Transaction.new(
          optional: { billing_address: address
          } )
      t.set_shipping_same_as_billing

      t.shipping_address.must_equal t.billing_address
    end

  end

  it "can be set to void a transaction" do
    t = PayTrace::Transaction.new(optional:{transaction_id:"11"})
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


end
