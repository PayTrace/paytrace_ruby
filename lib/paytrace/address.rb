module PayTrace
  class Address
    attr :name, :street,:street2,:city,:state, :country,:region,:postal_code,:address_type

    def initialize(options={})
      @name = options[:name]
      @street = options[:street]
      @street2 = options[:street2]
      @city = options[:city]
      @state = options[:state]
      @region = options[:region]
      @country = options[:country]
      @postal_code = options[:postal_code ]
      @address_type = options[:address_type] || :billing
    end

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
