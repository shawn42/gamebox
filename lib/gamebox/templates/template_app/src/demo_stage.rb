require 'stage'
require 'rubygame/ftor'
class DemoStage < Stage
  def setup
    super
    @my_actor = create_actor :my_actor
    @my_actor.x = 10
    @my_actor.y = 10

    @stars = []
    20.times { @stars << Ftor.new(rand(viewport.width),rand(viewport.height)) }
  end

  def draw(target)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
    super
  end
end

