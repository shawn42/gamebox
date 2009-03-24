#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"

require 'rubygems'
require 'rubygame'
include Rubygame

require "environment"

require 'publisher'
require 'publisher_ext'
require 'inflector'
require 'constructor'
require 'diy'
require 'actor_factory'

class GameboxApp
  def self.run(argv,env)
    GameboxApp.new.start argv, env
  end

  def initialize
    @context = DIY::Context.from_file(APP_ROOT + '/config/objects.yml')
  end
  
  def setup
    Rubygame.init
    @game = @context[:game]
  end
  
  def main_loop
    @input_manager = @context[:input_manager]
    @input_manager.main_loop @game
  end

  def shutdown
    Rubygame.quit
  end

  def start(argv,env)
    setup

    main_loop

    shutdown
  end
end

if $0 == __FILE__
  GameboxApp.run ARGV, ENV
end
