class ActorView
  attr_accessor :actor, :mode
  def initialize(mode,actor)
    @mode = mode
    @actor = actor
    actor.when :remove_me do
      @mode.unregister_drawable self
    end
    @mode.register_drawable self

    setup
  end

  def setup
  end
end

