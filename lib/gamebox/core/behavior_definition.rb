class BehaviorDefinition
  attr_accessor :setup_block, :remove_block, :required_injections, :react_to_block, :required_behaviors,
    :helpers_block, :source

  # Sets the dependencies for this Behavior.
  #
  # These will be pulled from the Actor's object context at view construction time.
  #
  #  requires :input_manager, :timer_manager, :director
  #
  def requires(*injections_needed)
    @required_injections = injections_needed
  end

  # Sets the behavior dependencies for this Behavior.
  #
  # Any behaviors listed here that are not on the actor will be constructed and added without any opts.
  #
  #  requires_behaviors :positioned
  #
  def requires_behaviors(*behaviors_needed)
    @required_behaviors = behaviors_needed
  end

  # Setup callback that is called when the behavior is added. The actor will
  # be set before your setup block is executed, and the opts method will be available.
  #
  #  setup do
  #    actor.has_attributes speed: opts[:speed]
  #    input_manager.when :down, KbSpace do
  #      jump
  #    end
  #  end
  #  
  def setup(&setup_block)
    @setup_block = setup_block
  end

  # Remove callback that is called when the behavior is removed. The actor will
  # still be available.
  #
  #  remove do
  #    input_manager.unsubscribe_all self
  #  end
  #  
  def remove(&remove_block)
    @remove_block = remove_block
  end

  # Override the default react_to method of the behavior. You should probably not be doing this and should be calling #reacts_with in #setup.
  #
  #  react_to do |message_type, *opts, &blk|
  #    case message_type
  #    when :blow_up
  #      ..
  #  end
  #  
  # @see Behavior#reacts_with
  def react_to(&react_to_block)
    @react_to_block = react_to_block
  end

  # Define methods and include modules for use by your behavior.
  #  helpers do
  #    include MyHelper
  #    def jump
  #      ...
  #    end
  #  end
  #  
  def helpers(&helpers_block)
    @helpers_block = helpers_block
  end
end
