require 'physical_level'
require 'physical_director'
class DemoLevel < PhysicalLevel
  def setup
    # TODO fix this to be configurable cleanly
    @space.gravity = vec2(0,0.001)

    @ground = @actor_factory.build :ground, self
    @ground.warp vec2(0,600)
    @ground.shape.e = 0.0004
    @ground.shape.u = 0.0004

    @nario = @actor_factory.build :nario, self
    @nario.warp vec2(300,500)

    @nario_dir = PhysicalDirector.new
    @nario_dir.add_actor @nario
    @directors << @nario_dir

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

