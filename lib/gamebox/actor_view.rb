class ActorView
  construct_with :stage, :wrapped_screen, :resource_manager, :actor
  public :stage, :wrapped_screen, :resource_manager, :actor

  attr_accessor :layer, :parallax
  def configure
    @layer = actor.do_or_do_not(:layer) || 0
    @parallax = actor.do_or_do_not(:parallax) || 1

    actor.when :remove_me do unregister  end
    actor.when :hide_me   do unregister  end
    actor.when :show_me   do register    end
    
    setup
  end

  def self.inherited(klass)
    klass.instance_eval do
      construct_with *ActorView.object_definition.component_names
      public *ActorView.object_definition.component_names
    end
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

