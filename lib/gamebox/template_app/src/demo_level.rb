require 'level'
require 'ftor'
class DemoLevel < Level
  def setup
    @my_actor = @actor_factory.build :my_actor, self
    @my_actor.x = 10
    @my_actor.y = 10

    @stars = []
    20.times { @stars << Ftor.new(rand(@width),rand(@height)) }
  end

  def draw(target)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

