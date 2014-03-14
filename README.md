# PayTrace Ruby SDK

![Build Status](https://www.codeship.io/projects/611ffe60-f3ee-0130-0299-1a84c3740ef1/status)

*This SDK is actively under development but should still be considered in an alpha
state. It does not provide all the access we are planning to our API at this time.
Please feel free to experiment with it and we will be regularly pushing out new
updates with increased functionality over the coming weeks*

This gem integrates with the PayTrace API. It provides functionality to the
publicly available functionality including:

 * Processing Transactions
 * Creating Customers
 * Exporting Transaction or Customer Data


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
class.

```ruby
transaction = Transaction.sale(
    {amount: "1.00",
    credit_card: {
        card_number: "1111222233334444",
        expiration_year: 14,
        expiration_month: 3
    }
  }
)

#
## Response information is available on the transaction
#
puts transaction.response_code # 101. Your transaction was successfully approved.

#
## All values returned are accessible through the attached response property
#
transaction.response.each do |key, value|
    puts key      # e.g. APPCODE
    puts value    # TAS671
end
```

### Customers

```ruby
# running a transaction for a customer
transaction = Transaction.sale({amount: "1.00",customer_id: "my_customer_id"})

```
### Some Optional Fields
```ruby
#Adding Optional Fields

transaction = Transaction.Sale(
  {
    amount: "1.00",
    credit_card: {
        card_number: "1111222233334444",
        expiration_year: 14,
        expiration_month: 3
    },
    email:"me@example.com",
    description:"This is a test",
    tax_amount:".50",
    discretionary_data:"This is some data that is discretionary"
  }
)

```

### Billing and Shipping Address
```ruby
transaction = Transaction.Sale(
    {amount: "1.00",
    credit_card: {
      card_number: "1111222233334444",
      expiration_year: 14,
      expiration_month: 3
    },  
    billing_address:{
        name:"Jane Doe",
        street:"1234 happy st.",
        street2:"apt#2",
        city:"Seattle",
        state:"WA",
        country: "US",
        postal_code:"98107"
    },
      shipping_address: {
        #Same as billing above.
      }
    }
)

```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
