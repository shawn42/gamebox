class EarthView < GraphicalActorView

  def draw(target, x_off, y_off, z)
    x = @actor.x
    y = @actor.y

    img = @actor.image
    img.draw x+x_off, y+y_off, z
  end
end

class Earth < Actor
  has_behavior :graphical, :layered 
end
