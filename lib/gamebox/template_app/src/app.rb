#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"

require 'environment'
require 'gamebox'

if $0 == __FILE__
  GameboxApp.run ARGV, ENV
end
