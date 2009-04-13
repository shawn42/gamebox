# Viewport represents the current "camera" location.  Essensially it translates from
# world to screen coords and from screen coords to world coords.
class Viewport
  attr_accessor :x_offset, :y_offset
  def initialize
    @x_offset = 0
    @y_offset = 0
  end

  # TODO make follow an actor?

  # TODO Add method for computing x/y offset for parallax
  # scrolling
end
