require 'director'
require 'publisher'
class ShipDirector < Director
  extend Publisher

  def setup
    @dead_actors = []
  end

  can_fire :create_bullet
  def actor_added(actor)
    if actor.is_a? Ship
      actor.when :shoot do
        # create bullet 
        fire :create_bullet, actor
      end
    end
  end

  def kill_actor(actor)
    @dead_actors << actor
  end

  # TODO put actor death into parent class
  def update(time)
    @actors -= @dead_actors
    @dead_actors = []
    for dir in @actors
      dir.update time
    end
  end
end
