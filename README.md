# PayTrace Ruby SDK

![Build Status](https://www.codeship.io/projects/611ffe60-f3ee-0130-0299-1a84c3740ef1/status)

This gem integrates with the PayTrace API. It provides functionality to the
publicly available functionality including:

 * Processing Transactions
 * Creating Customers
 * Exporting Transaction or Customer Data

 Note that the gem is intended to be a "thin shim" around the public API, cleaning up and organizing the URL-based function calls. It is designed to be consumed by other code for payment processing.

## Installation

Add this line to your application's Gemfile:

    gem 'paytrace'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paytrace

## Usage

### Configuring your account

You can set this up as a Rails initializer or during any other common configuration
of your application.

```ruby
PayTrace.configure do |config|
    config.user_name = "my_user_name"
    config.password = "password"
end
```

### Transactions

Transactions can be processed utilizing class methods on the PayTrace::Transaction
class. A simple example:

```ruby
response = Transaction.sale(
    {
      amount: "1.00",
      card_number: "1111222233334444",
      expiration_year: 14,
      expiration_month: 3
    }
  }
)

#
## Response information is available on the transaction
#
puts response.get_response() # 101. Your transaction was successfully approved.

#
## All values returned are accessible through the response
#
response.values do |key, value|
    puts key      # e.g. APPCODE
    puts value    # TAS671
end
```

### Customers

```ruby
# running a transaction for a customer
Transaction.sale({amount: "1.00",customer: my_customer_id})

```
### Some Optional Fields
```ruby
#Adding Optional Fields

Transaction.Sale(
  {
    amount: "1.00",
    card_number: "1111222233334444",
    expiration_year: 14,
    expiration_month: 3,
    email:"me@example.com",
    description:"This is a test",
    tax_amount:".50",
    discretionary_data: {hair_color: "red"}
  }
)

```

### Billing and Shipping Address
```ruby
Transaction.Sale(
    {
      amount: "1.00",
      card_number: "1111222233334444",
      expiration_year: 14,
      expiration_month: 3,  
      billing_name:"Jane Doe",
      billing_address:"1234 happy st.",
      billing_address2:"apt#2",
      billing_city:"Seattle",
      billing_state:"WA",
      billing_country: "US",
      billing_postal_code:"98107"
    })

```

## Deprecation

This Ruby gem code references our Legacy API which PayTrace no longer encourage to integrate with. 

PayTrace has a new API with Client-Side Encryption support. You can find related documentation, integration info and available samplecode at: https://developers.paytrace.com/support/home

If you have any questions or concerns, please feel free to reach out to our Technical support at: developersupport@paytrace.com.




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
