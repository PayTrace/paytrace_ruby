module PayTrace
  # Abstracts an address -- two types are possible, shipping and billing.
  # _Note:_ the "region" parameter can only be defined for shipping addresses, and the
  # default address type (if unspecified) is billing.
  class Address
    attr_accessor :name, :street,:street2,:city,:state, :country,:region,:postal_code,:address_type

    # Initialize a new address instance. Parameters are symbolic keys in a hash. They are:
    # * *:name* -- the name on this address
    # * *:street* -- the street address
    # * *:street2* -- an optional second line of street address (apartment, suite, etc.)
    # * *:city* -- the city
    # * *:state* -- the state 
    # * *:country* -- the country
    # * *:postal_code* -- the postal/zip code
    # * *:address_type* -- either :billing or :shipping
    # * *:region* -- the region (often county); note, only used for shipping addresses, ignored for billing addresses
    def initialize(options={})
      @name = options[:name]
      @street = options[:street]
      @street2 = options[:street2]
      @city = options[:city]
      @state = options[:state]
      @country = options[:country]
      @postal_code = options[:postal_code ]
      @address_type = options[:address_type] || :billing
      @region = options[:region] if @address_type == :shipping # special case for shipping addresses
    end

    # Applies the address parameters to a request object for proper formatting to the API
    # Parameters:
    # * *request* -- the request object to apply this address to
    def set_request(request)
      atype_str = address_type.to_s

      request.set_param(:"#{atype_str}_name", name) if name
      request.set_param(:"#{atype_str}_address", street) if street
      request.set_param(:"#{atype_str}_address2", street2) if street2
      request.set_param(:"#{atype_str}_city", city) if city
      request.set_param(:"#{atype_str}_region", region) if region
      request.set_param(:"#{atype_str}_state", state) if state
      request.set_param(:"#{atype_str}_postal_code", postal_code) if postal_code
      request.set_param(:"#{atype_str}_country", country) if country
    end
  end
end
