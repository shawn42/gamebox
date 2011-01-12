

class StarryNightView < ActorView
  def draw(target, x_off, y_off, z)
    for star in actor.stars
      target.draw_circle_filled(star.x,star.y,1,[255,255,255,255],z)
    end
  end
end
class StarryNight < Actor
  has_behavior :layered => {:layer => -1}
  attr_reader :stars
  def setup
    @stars = []
    20.times { @stars << Ftor.new(rand(@opts[:width]),rand(@opts[:height])) }
  end
end
