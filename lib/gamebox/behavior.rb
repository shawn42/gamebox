# Behavior is any type of behavior an actor can exibit.
class Behavior
  attr_accessor :actor, :opts

  def initialize(actor,opts={})
    @actor = actor
    @opts = opts
    req_behs = self.class.required_behaviors
    req_behs.each do |beh|
      unless @actor.is? beh
        @actor.is beh
      end
    end
    setup
  end

  def setup
  end

  def removed
  end

  def update(time)
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
