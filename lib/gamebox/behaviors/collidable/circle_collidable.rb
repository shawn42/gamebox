

class CircleCollidable < CollidableShape

  def setup
    @radius ||= opts[:radius]
  end

  def center_x
    actor_x + radius
  end

  def center_y
    actor_y + radius
  end

end
