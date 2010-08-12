class ActorView
  attr_accessor :actor, :stage, :layer, :parallax, :wrapped_screen
  def initialize(stage, actor, wrapped_screen)
    @stage = stage
    @actor = actor
    @wrapped_screen = wrapped_screen

    @layer = 0
    @parallax = 1
    if @actor.is? :layered
      @layer = @actor.layer
      @parallax = @actor.parallax
    end

    actor.when :remove_me do unregister end
    
    actor.when :hide_me do unregister  end
    
    actor.when :show_me do register end
    
    setup
  end
  
  def register
    @stage.register_drawable self
  end
  
  def unregister
    @stage.unregister_drawable self
  end

  def setup
  end

end

