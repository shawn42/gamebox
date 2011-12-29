if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end 
end

here = File.dirname(__FILE__)
gamebox_root = File.expand_path(File.join(here, '..', 'lib'))

require 'pry'
require File.join(File.dirname(__FILE__),'..', 'lib', 'gamebox')
require File.join(File.dirname(__FILE__),'..', 'lib', 'gamebox', 'spec', 'helper')
RSpec.configure do |config|
  config.mock_with :mocha
end
