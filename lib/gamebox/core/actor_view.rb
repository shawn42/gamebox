class ActorView
  # TODO remove stage
  construct_with :renderer, :wrapped_screen, :resource_manager, :actor, :stage
  public :wrapped_screen, :resource_manager, :actor, :stage

  attr_accessor :layer, :parallax
  def initialize
    @layer = actor.do_or_do_not(:layer) || 0
    @parallax = actor.do_or_do_not(:parallax) || 1

    # TODO clean up the show/hide here make nice with visible behavior?
    actor.when :remove_me do unregister  end
    actor.when :hide_me   do unregister  end
    actor.when :show_me   do register    end
    
  end

  def register
    renderer.register_drawable self
  end
  
  def unregister
    renderer.unregister_drawable self
  end

  def screen_width
    @screen_width ||= wrapped_screen.width
  end

  def screen_height
    @screen_height ||= wrapped_screen.height
  end

  class << self
    def define(actor_view_type, &blk)
      @definitions ||= {}
      definition = ActorViewDefinition.new
      definition.instance_eval &blk if block_given?
      @definitions[actor_view_type] = definition
    end

    def definitions
      @definitions ||= {}
    end
  end

end
