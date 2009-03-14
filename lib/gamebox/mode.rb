# Mode is a state that the game is in.  (ie intro mode, multiplayer mode,
# single player mode).
class Mode
  attr_accessor :level, :drawables
  def initialize
    @drawables = {}
  end

  def start
  end

  def stop
  end

  def events
    []
  end

  def update(time)
    @level.update time if @level
  end

  def draw(target)
    target.fill [255,255,255,255]
    @level.draw target
    for d in @drawables.values
      d.draw target
    end
  end

  def unregister_drawable(drawable)
    @drawables.delete drawable
  end

  def register_drawable(drawable)
    @drawables[drawable] = drawable
  end
end

