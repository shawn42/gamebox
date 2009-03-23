# Directors manage actors.
class Director
  attr_accessor :actors

  def initialize
    @actors = []
    @dead_actors = []
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
    @dead_actors << actor
  end

  def actor_removed(actor)
  end

  def actor_added(actor)
  end

  def empty?
    @actors.empty?
  end

  def update(time)
    for act in @dead_actors
      @actors.delete act
      actor_removed act
    end
    for act in @actors
      act.update time
    end
  end
end
