# This class handles the abstract representation of the Tetris grid
# and conversions from grid cells to hard x and y coordinates in screen space
class Grid

  attr_reader :rows, :columns
  attr_accessor :screen_x, :screen_y

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

  # Adds a new playing piece to the field and 
  # returns [x,y] of where a new piece needs to be placed.
  # This is an offset from this grid's location, and assumes
  # the grid is drawn at 0,0. If different, make srue these values
  # are modified properly
  def new_piece(piece)
    @falling_piece = piece

    col = @columns / 2 - 1
    row = 0

    @falling_piece.x = col * @block_size + self.screen_x
    @falling_piece.y = row * @block_size + self.screen_y
  end

  # Move the piece down one row
  def piece_down
    @falling_piece.y += @block_size

    # Not at the bottom yet
    return false 
  end

  # Drop piece to the bottom 
  def drop_piece
    @falling_piece.y = self.screen_y + (@rows * @block_size) - @block_size
  end

  # Move to the left
  def piece_left
    @falling_piece.x -= @block_size
  end

  # Move to the right
  def piece_right
    @falling_piece.x += @block_size
  end

end
