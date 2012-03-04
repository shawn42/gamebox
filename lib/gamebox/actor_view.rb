class ActorView
  construct_with :stage, :wrapped_screen
  attr_accessor :actor, :layer, :parallax
  def configure(actor)
    @actor = actor

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
    stage.register_drawable self
  end
  
  def unregister
    stage.unregister_drawable self
  end

  def setup
  end

  def screen_width
    @screen_width ||= wrapped_screen.width
  end

  def screen_height
    @screen_height ||= wrapped_screen.height
  end

end

