module Gamebox
  # Returns the global configuration object
  def self.configuration
    @configuration ||= Configuration.new
    @configuration
  end

  def self.configure
    yield configuration if block_given?
  end

  def define_behavior(name, &blk)
    Behavior.define name, &blk
  end

  def define_actor(name, &blk)
    Actor.define name, &blk
  end

  def define_actor_view(name, &blk)
    ActorView.define name, &blk
  end

  # module_function :define_behavior, :define_actor, :define_actor_view


end

# EEK... dirty?
include Gamebox
