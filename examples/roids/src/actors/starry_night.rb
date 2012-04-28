__END__
class StarryNightView < ActorView
  def setup
    @color = [255,255,255,255]
  end
  def draw(target, x_off, y_off, z)
    for star in actor.stars
      target.draw_circle_filled(star[0], star[1], 1, @color, z)
    end
  end
end

class StarryNight < Actor
  has_behavior :layered => {:layer => -1}
  has_behavior :updatable
  attr_reader :stars
  def setup
    @stars = []
    20.times { @stars << [rand(@opts[:width]), rand(@opts[:height]), rand/5.0] }
  end

  def update(time)
    @stars.each do |star| 
      star[1] = (star[1] + star[2] * time) % @opts[:height]
    end
  end
end
