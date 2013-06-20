# Behavior is any type of behavior an actor can exibit.
class Behavior
  construct_with :actor, :behavior_factory

  attr_accessor :opts

  # Specifies messages that your behavior is interested in and
  # that you have defined methods for in your helpers block.
  #
  #  reacts_with :remove
  #
  #  helpers do
  #    def remove
  #      input_manager.unsubscribe_all self
  #    end
  #  end
  def reacts_with(*messages_with_methods)
    @message_handlers ||= Set.new
    @message_handlers.merge(messages_with_methods)
  end

  # Dispatches reactions to helper methods based on name.
  # See BehaviorDefinition to see how to override this.
  # 
  # @see BehaviorDefinition
  # @see Actor#react_to
  def react_to(message_type, *opts, &blk)
    if @message_handlers && @message_handlers.include?(message_type)
      send message_type, *opts, &blk
    end
  end

  # Builds and adds a behavior based on the name and options passed in.
  #
  #  actor.input.when :shields_up do
  #    add_behavior :invincible, duration: actor.shield_charge
  #  end
  #
  def add_behavior(behavior_name, opts = {})
    behavior_factory.add_behavior actor, behavior_name, opts
  end

  # Removes the behavior by name. Any added attributes will remain on the actor.
  #
  #  actor.input.when :shields_down do
  #    remove_behavior :invincible
  #  end
  #
  def remove_behavior(behavior_name)
    actor.remove_behavior(behavior_name)
  end

  class << self

    def define(behavior_type, &blk)
      @definitions ||= {}
      definition = BehaviorDefinition.new
      definition.source = caller.detect{|c|!c.match /core/}
      definition.instance_eval &blk if block_given?
      @definitions[behavior_type] = definition
    end

    def definitions
      @definitions ||= {}
    end
  end
end
