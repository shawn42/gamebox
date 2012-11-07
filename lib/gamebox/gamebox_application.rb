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

  def start(argv,env)
    setup(argv,env)
    main_loop
    shutdown
  end

  def setup(argv,env)
    @game = @context[:game]
    @game.configure
    config_manager = @game.config_manager
    self.class.post_setup_handlers.each { |handler| handler.setup(argv, env, config_manager) }
  end

  def main_loop
    @input_manager = @context[:input_manager]
    @input_manager.register @game
    @input_manager.show
  end

  def shutdown ; end

  def self.register_post_setup_handler(handler)
    post_setup_handlers.push handler
  end

  def self.post_setup_handlers
    @post_setup_handlers ||= [ ]
  end

end

if $0 == __FILE__
  GameboxApp.run ARGV, ENV
end
