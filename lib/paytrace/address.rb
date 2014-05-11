module PayTrace
  # Abstracts an address -- two types are possible, shipping and billing.
  # _Note:_ the "region" parameter can only be defined for shipping addresses, and the
  # default address type (if unspecified) is billing.
  class Address
    # :nodoc:
    attr_accessor :name, :street,:street2,:city,:state, :country,:region,:postal_code,:address_type

    ATTRIBUTE_MAP = [
      [:name, :name],
      [:address, :street],
      [:address2, :street2],
      [:city, :city],
      [:region, :region],
      [:state, :state],
      [:postal_code, :postal_code],
      [:country, :country]
    ]
    # :doc:

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
      ATTRIBUTE_MAP.each do |request_name, attribute_name|   
        unless request_name == :region && address_type == :billing # special case
          # this is ugly, but it saves us from subclassing just to change field names in a predictable way...
          request.set_param("#{address_type.to_s}_#{request_name}".to_sym, self.send(attribute_name))
        end
      end
    end
  end
end
