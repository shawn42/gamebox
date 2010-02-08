# Behavior is any type of behavior an actor can exibit.
class Behavior
  attr_accessor :actor, :opts

  def initialize(actor,opts={})
    @actor = actor
    @opts = opts
    setup
  end

  def setup
  end

  def removed
  end

  def update(time)
  end
end
