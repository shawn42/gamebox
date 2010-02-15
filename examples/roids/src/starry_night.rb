require 'rubygame/ftor'
class StarryNightView < ActorView
  def draw(target, x_off, y_off)
    for star in actor.stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
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
