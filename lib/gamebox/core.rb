module Gamebox
  # Returns the global configuration object
  def self.configuration
    @configuration ||= Configuration.new
    @configuration
  end

  def self.configure
    yield configuration if block_given?
  end

end

