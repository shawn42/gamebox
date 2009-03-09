# Behavior is any type of behavior an actor can exibit.
class Behavior

  def initialize(actor)
    @actor = actor
    setup
  end

  def setup
  end

  def update(time)
  end
end
