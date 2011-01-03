


class PrettyGemView < ActorView
  def draw(target, x_off, y_off, z)
    x = @actor.x
    y = @actor.y

    rot = @actor.rotation

    @actor.image.draw_rot x+x_off, y+y_off, z, rot
  end
end

class PrettyGem < Actor
  has_behavior :graphical, :dancing, :updatable, :layered 
end
