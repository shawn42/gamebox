# Directors manage actors.
class Director
  attr_accessor :actors

  def initialize
    @actors = []
    setup
  end

  def setup
  end

  def add_actor(actor)
    @actors << actor
    actor.when :remove_me do
      remove_actor actor
    end
    actor_added actor
  end

  def remove_actor(actor)
    @actors.delete actor
    actor_removed actor
  end

  def actor_removed(actor)
  end

  def actor_added(actor)
  end

  def update(time)
    for act in @actors
      act.update time
    end
  end
end
