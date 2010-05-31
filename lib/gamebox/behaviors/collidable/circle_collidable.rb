require 'collidable/collidable_shape'

class CircleCollidable < CollidableShape

  def setup
    @radius ||= opts[:radius]
  end

  def center_x
    @actor.x + radius
  end

  def center_y
    @actor.y + radius
  end

end
