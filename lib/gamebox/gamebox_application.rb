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
    gamebox_objects = YAML.load(File.read(GAMEBOX_PATH + 'data/config/objects.yml'))

    game_objects_file = APP_ROOT + '/config/objects.yml'
    game_specific_objects = {}
    if File.exist? game_objects_file
      game_specific_objects = YAML.load(File.read(game_objects_file))
    end
    objects = gamebox_objects.merge! game_specific_objects

    @context = DIY::Context.from_yaml(YAML.dump(objects))
  end
  
  def setup
    @game = @context[:game]
    
    @config_manager = @context[:config_manager]
    setup_debug_server if @config_manager[:debug_server] || ARGV.include?("-debug-server")
  end
  
  def setup_debug_server
    # 
    # require 'drb'
    # self.class.extend DRbUndumped
    # puts "Starting debug server..."
    # 
    # DRb.start_service "druby://localhost:7373", self
    # puts "on #{DRb.uri}"
    Thread.new do
      binding.remote_pry
    end
  end
  
  def main_loop
    @input_manager = @context[:input_manager]
    @input_manager.main_loop @game
  end

  def shutdown
  end
  
  def debug_eval(eval_str)
    instance_eval eval_str
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
