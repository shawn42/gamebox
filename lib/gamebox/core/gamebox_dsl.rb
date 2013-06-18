module GameboxDSL

  # Defines a stage; a stage is a game mode. (ie :main_menu, :play, or :credits)
  #
  #  will raise an erorr if the stage already exists
  #  example:
  # 
  #  define_stage :main_menu do
  #    # injects your dependencies; will construct if needed
  #    requires :input_manager, :customer_monkey_factory
  #
  #    # callback for stage setup
  #    curtain_up &block
  #
  #    # callback for stage teardown
  #    curtain_down &block
  #
  #    # redefine the renderer for this stage, Gamebox has a default Renderer
  #    # if unspecified 
  #    render_with :my_custom_renderer
  #
  #    # define any helper methods and include any needed modules
  #    helpers &block
  #  
  #  end
  #
  # @see StageDefinition
  def define_stage(name, &blk)
    Stage.define name, &blk
  end

  # Defines a behavior type. (ie :jumper or :shooter)
  #
  #  will raise an erorr if the behavior already exists
  #  example:
  # 
  #  define_behavior :jumper do
  #    # injects your dependencies; will construct if needed
  #    requires :input_manager, :timer_manager, :stage
  #
  #    # adds the required behaviors to your actor if not present
  #    $ NOTE: no options can be passed to the added behavior
  #    required_behaviors :positioned
  #
  #    # callback when your behavior has been added to an actor
  #    # #opts will be populated with any args that were specified on behavior
  #    # addition 
  #    setup &block
  #
  #    # define a custom handler for reacting to your actor's messages
  #    # @see Behavior#reacts_with for recommended message dispatch
  #    react_to &block
  #
  #    # define any helper methods and include any needed modules
  #    helpers &block
  #  
  #  end
  #
  # @see BehaviorDefinition
  def define_behavior(name, &blk)
    Behavior.define name, &blk
  end

  # Defines an actor type, (ie :plumber)
  # Optionally adding attributes, behaviors and a view.
  #
  #  will raise an erorr if the actor already exists
  #  example:
  # 
  #  define_actor :plumber do
  #    # define default attributes and values
  #    has_attribute x: 5
  #    has_attributes x: 7, y: 12
  #
  #    # define default behaviors and their options options can be
  #    #   - list of behavior names
  #    #   - hash of behavior names to options for each behavior
  #    #   - block form
  #    has_behavior :postitioned
  #    has_behaviors do
  #      jumper max: 12, double: true
  #    end
  #  
  #    # Allows the inlining of one behavior in this actor.
  #    # It is equivalent to creating a behavior with the same name as the actor,
  #    # and adding it to the actor.
  #    #
  #    # The block works the same as calling #define_behavior.
  #    behavior
  #      
  #    # Allows the inline of a view in this actor
  #    # It is equivalent to creating an actor view with the same name as the actor.
  #    # 
  #    # The block works the same as calling #define_actor_view.
  #    view
  #  
  #  end
  #
  # @see ActorDefinition
  def define_actor(name, &blk)
    Actor.define name, &blk
  end

  # Defines an actor view type. (ie :plumber_view)
  #
  #  will be constructed when any actor with matching name is created
  #  ie: :ship_view will be created and shown for any actor :ship that is created
  #
  #  will raise an erorr if the actor view already exists
  #  example:
  # 
  #  define_actor :plumber_view do
  #    # injects your dependencies; will construct if needed
  #    requires :input_manager, :customer_monkey_factory
  #
  #    # callback when your view is created
  #    # #actor will be available at this time
  #    setup &block
  #
  #    # define any helper methods and include any needed modules
  #    helpers &block
  #  
  #  end
  #
  # @see ActorViewDefinition
  def define_actor_view(name, &blk)
    ActorView.define name, &blk
  end
end
