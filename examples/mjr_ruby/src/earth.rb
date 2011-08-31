class EarthView < GraphicalActorView

  def draw(target, x_off, y_off, z)
    x = @actor.x
    y = @actor.y

    img = @actor.image
    w = img.width
    h = img.height
    @hw ||= w/2.0
    @hh ||= h/2.0
    img.draw @hw+x+x_off, @hh+y+y_off, z
  end
end

class Earth < Actor
  has_behavior :graphical, :layered 
end
