

class CircleCollidable < CollidableShape

  def setup
    @radius ||= opts[:radius]
  end

  def center_x
    actor_x
  end

  def center_y
    actor_y
  end

end
