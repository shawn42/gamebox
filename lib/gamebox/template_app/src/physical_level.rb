# Levels represent on level of game play.  Some games will likely have only one
# level. Level is responsible for loading its background, props, and directors.
# PhysicalLevel adds a physics space to the Level
require 'level'
require 'physics'
class PhysicalLevel < Level
  #  GRAVITY = 0.01
  DAMPING = 0.8

  def initialize
    @directors = []
    @space = Space.new
    @space.iterations = 4
    @space.damping = DAMPING
    # TODO make gravity configurable/optional
    #    @space.gravity = vec2(0,GRAVITY)
    setup
  end

  def update(time)
    @space.step time
    for dir in @directors
      dir.update time
    end
  end

  def register_physical_object(obj)
    @space.add_body(obj.body)
    @space.add_shape(obj.shape)
  end

end
