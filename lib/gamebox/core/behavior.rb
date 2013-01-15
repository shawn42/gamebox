# Behavior is any type of behavior an actor can exibit.
class Behavior
  construct_with :actor, :behavior_factory

  attr_accessor :opts

  def configure(opts={})
    @opts = opts
    setup
  end

  def setup
  end

  def reacts_with(*messages_with_methods)
    # TODO do a merge here..
    @message_handlers = messages_with_methods
  end

  def react_to(message_type, *opts, &blk)
    # TODO perf analysis, should I use a hash here?
    if @message_handlers && @message_handlers.include?(message_type)
      send message_type, *opts, &blk
    end
  end

  def add_behavior(behavior_name, opts = {})
    behavior_factory.add_behavior actor, behavior_name, opts
  end

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
