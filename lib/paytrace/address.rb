module PayTrace
  class Address
    attr :name, :street,:street2,:city,:state, :country, :postal_code

    def initialize(options={})
      @name = options[:name]
      @street = options[:street]
      @street2 = options[:street2]
      @city = options[:city]
      @state = options[:state]
      @country = options[:country]
      @postal_code = options[:postal_code ]
    end
  end
end
