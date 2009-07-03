$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'gamebox'))

require 'rubygems'
require 'spec'

#require 'bacon'
#require 'mocha'
#require 'aliasing'

#class Bacon::Context
#  include Mocha::Standalone
#  def it_with_mocha description
#    it_without_mocha description do
#      mocha_setup
#      yield
#      mocha_verify
#      mocha_teardown
#    end
#  end
#  alias_method_chain :it, :mocha
#end


require 'metaclass'
require 'actor'

