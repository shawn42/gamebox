class ActorView
  attr_accessor :actor, :mode, :layer, :parallax
  def initialize(mode,actor)
    @mode = mode
    @actor = actor

    @layer = 0
    @parallax = 1
    if @actor.is? :layered
      @layer = @actor.layer
      @parallax = @actor.parallax
    end

    actor.when :remove_me do
      @mode.unregister_drawable self
    end
    
    actor.when :hide_me do
      @mode.unregister_drawable self
    end
    
    actor.when :show_me do
      @mode.register_drawable self
    end
    
    setup
  end

  def setup
  end

end

