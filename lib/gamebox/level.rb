# Levels represent on level of game play.  Some games will likely have only one
# level. Level is responsible for loading its background, props, and directors.
require 'inflector'
class Level

  attr_accessor :directors
  def initialize(actor_factory)
    @actor_factory = actor_factory
    @directors = []
    setup
  end

  def setup
  end

  def update(time)
    for dir in @directors
      dir.update time
    end
  end

  def draw(target)
    for dir in @directors
      dir.draw target
    end
  end
end
