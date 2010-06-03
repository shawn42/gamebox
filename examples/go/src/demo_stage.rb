require 'stage'
class DemoStage < Stage
  def setup
    super
    @my_actor = create_actor :my_actor
    @my_actor.x = 10
    @my_actor.y = 10
  end

  def draw(target)
#    puts "DRAW CALLED"
#    target.fill [25,25,25,255]
#    for star in @stars
#      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
#    end
    super
  end
end

