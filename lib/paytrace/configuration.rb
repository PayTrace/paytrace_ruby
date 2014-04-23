module PayTrace
  class Configuration
    attr_accessor :user_name, :password, :connection, :domain, :path

    RESET_PASSWORD_METHOD = "UpdatePassword"

    def initialize
      @domain = "paytrace.com"
      @connection = Faraday.new
      @path = "api/default.pay"
    end

    def update_password(params)
      request = PayTrace::API::Request.new
      request.set_param(:method, RESET_PASSWORD_METHOD)
      request.set_params([:new_password, :new_password_confirmation], params)
      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)   

      unless response.has_errors?
        PayTrace.configure do |config|
          config.password = params[:new_password]
        end
      end 

      response
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
