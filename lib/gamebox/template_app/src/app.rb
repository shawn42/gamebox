#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"

require 'rubygems'
require 'rubygame'
include Rubygame

require "environment"

require 'publisher'
require 'constructor'
require 'diy'

class GameboxApp

  def initialize()
    @context = DIY::Context.from_file(APP_ROOT + '/config/objects.yml')
  end
  
  def setup()
    Rubygame.init
    @game = @context[:game]
  end
  
  def main_loop()
    @input_manager = @context[:input_manager]
    @input_manager.main_loop @game
  end

  def shutdown()
    Rubygame.quit
  end

  def run()
    setup

    main_loop

    shutdown
  end
end

console = false

if ARGV[0] == 'console'
  console = true
end

if $0 == __FILE__
  app = GameboxApp.new
  if console
    require 'drb'
    DRb.start_service("druby://:7777", app)
  end
  app.run
end
