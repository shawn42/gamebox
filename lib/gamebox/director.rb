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
    actor_added actor
  end

  def actor_added(actor)
  end

  def update(time)
    for act in @actors
      act.update time
    end
  end
end
