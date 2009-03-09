# Mode is a state that the game is in.  (ie intro mode, multiplayer mode,
# single player mode).
class Mode
  attr_accessor :level

  def update(time)
    @level.update time if @level
  end

  def draw(target)
    @level.draw target
  end
end

