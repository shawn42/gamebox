class ActorView
  attr_accessor :actor, :stage, :layer, :parallax
  def initialize(stage,actor)
    @stage = stage
    @actor = actor

    @layer = 0
    @parallax = 1
    if @actor.is? :layered
      @layer = @actor.layer
      @parallax = @actor.parallax
    end

    actor.when :remove_me do
      @stage.unregister_drawable self
    end
    
    actor.when :hide_me do
      @stage.unregister_drawable self
    end
    
    actor.when :show_me do
      @stage.register_drawable self
    end
    
    setup
  end

  def setup
  end

end

