# This class handles the abstract representation of the Tetris grid
# and conversions from grid cells to hard x and y coordinates in screen space
class Grid

  attr_reader :rows, :columns

  def initialize(columns, rows, block_size = 24)
    @rows = rows
    @columns = columns
    @block_size = block_size
    @field = Array.new(rows).map { Array.new(columns) }
  end

  # Get width of the field in pixels
  def width
    @columns * @block_size
  end

  # Get height of the field in pixels
  def height
    @rows * @block_size
  end

  # Returns [x,y] of where a new piece needs to be placed.
  # This is an offset from this grid's location, and assumes
  # the grid is drawn at 0,0. If different, make srue these values
  # are modified properly
  def new_piece_coords
    col = (@columns - 2) / 2
    row = 1

    [col * @block_size, row * @block_size]
  end

end
