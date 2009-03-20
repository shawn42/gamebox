require 'physical_director'
require 'publisher'
class ShipDirector < PhysicalDirector
  extend Publisher

  def setup
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

  def update(time)
    for dir in @actors
      dir.update time
    end
  end
end
