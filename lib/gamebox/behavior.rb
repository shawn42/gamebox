# Behavior is any type of behavior an actor can exibit.
class Behavior
  construct_with :actor

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

  def required_behaviors
    self.class.required_behaviors
  end

  class << self

    def required_behaviors
      @required_behaviors ||= []
    end

    def requires_behaviors(*args)
      @required_behaviors ||= []
      for a in args
        @required_behaviors << a
      end
      @behaviors
    end

    def requires_behavior(*args)
      requires_behaviors(*args)
    end

    def define(actor_type)
      @definitions ||= {}
      definition = BehaviorDefinition.new
      yield definition if block_given?
      @definitions[actor_type] = definition
    end

    def definitions
      @definitions ||= {}
    end
  end

  class BehaviorDefinition
    attr_accessor :setup_block, :required_injections
    def requires(*injections_needed)
      @required_injections = injections_needed
    end

    def setup(&setup_block)
      @setup_block = setup_block
    end
  end
end
