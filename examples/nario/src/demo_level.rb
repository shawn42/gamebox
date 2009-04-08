require 'physical_level'
require 'physical_director'
class DemoLevel < PhysicalLevel
  def setup
    # TODO fix this to be configurable cleanly
    @space.gravity = vec2(0,0.02)
    @space.iterations = 3
    @space.damping = 0.7

    @ground = create_actor :ground
    @ground.warp vec2(0,600)
    @ground.shape.e = 0.0004
    @ground.shape.u = 0.0004

    @nario = create_actor :nario
    @nario.warp vec2(300,500)

    @stars = []
    20.times { @stars << vec2(rand(@width),rand(@height)) }
  end

  def draw(target)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

