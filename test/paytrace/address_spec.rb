require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

describe PayTrace::Address do
  it "should accept an address type" do
    a = PayTrace::Address.new({address_type: :shipping})

    a.address_type.must_equal :shipping
  end

  it "should default to a billing address" do
    a = PayTrace::Address.new({})

    a.address_type.must_equal :billing
  end

  it "should skip blank fields" do
    a = PayTrace::Address.new({foo: :bar, baz: :bat})

    a.name.must_be_nil
    a.street.must_be_nil
    a.street2.must_be_nil
    a.city.must_be_nil
    a.state.must_be_nil
    a.country.must_be_nil
    a.region.must_be_nil
    a.postal_code.must_be_nil

    # special case: defaults to :billing
    a.address_type.wont_be_nil
  end

  it "should not add arbitrary fields" do
    a = PayTrace::Address.new({foo: :bar, baz: :bat})

    a.must_respond_to(:address_type)
    a.wont_respond_to(:foo)
    a.wont_respond_to(:baz)
  end


  it "should set the request fields correctly" do
    r = PayTrace::API::Request.new
    a = PayTrace::Address.new({
      name: "John Doe",
      street: "1234 Main Street",
      street2: "Apt. B",
      city: "Shoreline",
      state: "WA",
      country: "USA",
      region: "region??",
      postal_code: "98133",
      address_type: :shipping
      })
    a.set_request(r)

    r.params[:shipping_name].must_equal "John Doe"
    r.params[:shipping_address].must_equal "1234 Main Street"
    r.params[:shipping_address2].must_equal "Apt. B"
    r.params[:shipping_city].must_equal "Shoreline"
    r.params[:shipping_state].must_equal "WA"
    r.params[:shipping_country].must_equal "USA"
    r.params[:shipping_region].must_equal "region??"
    r.params[:shipping_postal_code].must_equal "98133"
  end
end