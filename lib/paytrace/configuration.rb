module PayTrace
  class Configuration
    attr_accessor :user_name, :password, :connection, :domain, :path

    def initialize
      @domain = "paytrace.com"
      @connection = Faraday.new
      @path = "api/default.pay"
    end

    def url
      "https://#{@domain}/#{@path}"
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure 
    yield(configuration) if block_given?
  end
end
