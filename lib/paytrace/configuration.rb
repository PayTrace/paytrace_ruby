module PayTrace
  class Configuration
    attr_accessor :user_name, :password
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure 
    yield(configuration) if block_given?
  end
end
