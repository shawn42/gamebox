#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"

begin
  # optional file
  require "environment" 
rescue LoadError => err
end

class GameboxApp
  attr_reader :context, :game
  def self.run(argv,env)
    GameboxApp.new.start argv, env
  end

  def initialize
    @context = Conject.default_object_context
  end

  def setup
    @game = @context[:game]
    @game.configure
    @config_manager = @context[:config_manager]
    setup_debug_server if @config_manager[:debug] || ARGV.include?("--debug")
  end

  def setup_debug_server
    self.class.send(:include, DebugHelpers)
    Thread.new do
      loop do
        begin
          if th = DRb.thread
            th.kill
          end

          binding.remote_pry
          log "remote_pry returned"
        rescue Exception => e
          log "finished remote pry"
        end
      end
    end
  end

  def main_loop
    @input_manager = @context[:input_manager]
    @input_manager.register @game
    @input_manager.show
  end

  def shutdown
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
