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
    @message_handlers = messages_with_methods
  end

  def react_to(message_type, *opts)
    # TODO perf analysis, should I use a hash here?
    if @message_handlers && @message_handlers.include?(message_type)
      send message_type, *opts
    end
  end

  def add_behavior(behavior_name, opts = {})
    actor.add_behavior behavior_name, opts
  end

  class << self

    def define(behavior_type, &blk)
      @definitions ||= {}
      definition = BehaviorDefinition.new
      definition.instance_eval &blk if block_given?
      @definitions[behavior_type] = definition
    end

    def definitions
      @definitions ||= {}
    end
  end

  class BehaviorDefinition
    attr_accessor :setup_block, :required_injections, :react_to_block, :required_behaviors,
      :helpers_block

    def requires(*injections_needed)
      @required_injections = injections_needed
    end

    def requires_behaviors(*behaviors_needed)
      @required_behaviors = behaviors_needed
    end

    def setup(&setup_block)
      @setup_block = setup_block
    end

    def react_to(&react_to_block)
      @react_to_block = react_to_block
    end

    def helpers(&helpers_block)
      @helpers_block = helpers_block
    end
  end
end
