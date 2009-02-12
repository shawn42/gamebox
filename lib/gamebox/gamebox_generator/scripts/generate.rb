require File.dirname(__FILE__) + '/../scripts'

module Gamebox::Generator::Scripts
  class Generate < Base
    mandatory_options :command => :create
  end
end
