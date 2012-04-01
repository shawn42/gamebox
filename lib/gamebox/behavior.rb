# Behavior is any type of behavior an actor can exibit.
class Behavior
  attr_accessor :opts

  def configure(opts={})
    @opts = opts
    setup
  end

  def setup
  end

  def react_to(message_type, *opts)
  end

  def required_behaviors
    self.class.required_behaviors
  end

  def self.required_behaviors
    @required_behaviors ||= []
  end

  def self.requires_behaviors(*args)
    @required_behaviors ||= []
    for a in args
      @required_behaviors << a
    end
    @behaviors
  end

  def self.requires_behavior(*args)
    requires_behaviors(*args)
  end
end
