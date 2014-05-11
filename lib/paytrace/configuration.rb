module PayTrace
  # Contains necessary configuration to access the API server; notably the user name, password, and URL information
  class Configuration
    # :nodoc:
    attr_accessor :user_name, :password, :connection, :domain, :path

    RESET_PASSWORD_METHOD = "UpdatePassword"
    # :doc:

    # Default initializer. Do not call directly; instead use the PayTrace.configure method
    # Example:
    #       PayTrace.configure do |config|
    #         config.user_name = "demo123"
    #         config.password = "password"
    #         config.domain = "stage.paytrace.com"
    #         config.path = "api/default.pay"
    #       end
    #
    # _Note:_ sane defaults are provided for the domain and path; typically you only need to supply the user name and password.
    def initialize
      @domain = "paytrace.com"
      @connection = Faraday.new
      @path = "api/default.pay"
    end

    # Updates the API password. Parameters are passed in a hash. They are:
    # * *:new_password* -- the new password to use
    def update_password(params)
      request = PayTrace::API::Request.new
      request.set_param(:method, RESET_PASSWORD_METHOD)
      request.set_param(:new_password, params[:new_password])
      request.set_param(:new_password_confirmation, params[:new_password])
      gateway = PayTrace::API::Gateway.new
      response = gateway.send_request(request)   

      unless response.has_errors?
        PayTrace.configure do |config|
          config.password = params[:new_password]
        end
      end 

      response
    end

    # Returns the API URL, based off the domain and path configured.
    def url
      "https://#{@domain}/#{@path}"
    end
  end

  # Returns the singleton Configuration object
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Allows setting configuration properties via a yield block.
  # :yields: a Configuration object.
  def self.configure 
    yield(configuration) if block_given?
  end
end
