require 'publisher'

# This class handles the abstract representation of the Tetris grid
# and conversions from grid cells to hard x and y coordinates in screen space.
#
# This class also contains an experiement in tetris collision detection. Basically,
# there are no walls or a floor, but a top-open box made of "blocks". Grid here
# will keep track of where real pieces are and abstract out this box, but this
# should very much simplify collision detection routines. As a visual, the box will look
# like the following for a 4x8 grid:
#
#   X _ _ _ _ X
#   X _ _ _ _ X
#   X _ _ _ _ X
#   X _ _ _ _ X
#   X _ _ _ _ X
#   X _ _ _ _ X
#   X _ _ _ _ X
#   X _ _ _ _ X
#   X X X X X X
#
class Grid
  extend Publisher

  can_fire :game_over, :next_level

  attr_reader :rows, :columns
  attr_accessor :screen_x, :screen_y

  TETROMINOS = [:square, :j, :l, :bar, :t, :s, :z]

  def initialize(columns, rows, block_size = 24)
    @rows = rows
    @columns = columns
    @block_size = block_size

    # Keep track of game progression
    @line_count = 0
    @tnl = 10

    # Build our internal Box representation
    @field = Array.new(rows)

    (rows + 1).times do |row|
      @field[row] = Array.new(columns + 2)
      (columns + 2).times do |col|
        @field[row][0] = 1
        @field[row][-1] = 1
      end
    end

    (columns + 2).times do |col|
      @field[-1][col] = 1
    end

    print_field
  end

  # Get width of the field in pixels
  def width
    @columns * @block_size
  end

  # Get height of the field in pixels
  def height
    @rows * @block_size
  end

  def playing?
    !@parent.nil?
  end

  # Begin Tetris.
  # Give the block the x and y pixel values of the parent actor
  def start_play(actor, stage)
    @parent = actor
    @stage = stage
    self.screen_x = @parent.x
    self.screen_y = @parent.y

    @game_info = stage.create_actor :game_info, x: self.screen_x + self.width + 40, y: self.screen_y + 240, score: 0, current_level: 1

    next_tetromino
    new_piece
  end

  def game_over
    puts "GAME OVER!"
    @parent = @falling_piece = nil
    print_field

    fire :game_over
  end

  def next_level
    @game_info.score += 100
    @game_info.current_level += 1
    @line_count = 0
    @tnl += 10

    fire :next_level
  end

  # Adds a new playing piece to the field and
  # returns [x,y] of where a new piece needs to be placed.
  # This is an offset from this grid's location, and assumes
  # the grid is drawn at 0,0. If different, make sure these values
  # are modified properly
  def new_piece
    next_tetromino

    col = @columns / 2 - 1
    row = 0

    @falling_piece.x = col * @block_size + self.screen_x
    @falling_piece.y = row * @block_size + self.screen_y

    @falling_piece.grid_position.x = col + 1
    @falling_piece.grid_position.y = row

    if collides?
      game_over
    end
  end

  def next_tetromino
    @falling_piece = @waiting_piece

    type = TETROMINOS[rand(TETROMINOS.length)]
    @waiting_piece = @stage.create_actor type, x: self.screen_x + self.width + 80, y: self.screen_y + 40

    @waiting_piece
  end

  # Move the piece down one row
  def piece_down
    return unless @falling_piece

    @falling_piece.y += @block_size
    @falling_piece.grid_position.y += 1

    # If we collide going down, we're done and next
    # piece needs to start
    if collides?
      piece_up
      piece_finished
      true
    else
      false
    end
  end

  # Move a piece back up a position
  def piece_up
    return unless @falling_piece

    @falling_piece.y -= @block_size
    @falling_piece.grid_position.y -= 1
  end

  # Drop piece to the bottom.
  # To make sure we only drop as far as collisions allow, we drop each row
  # and check collisions. Once we collide, move back up and freeze
  def drop_piece
    return unless @falling_piece

    loop do
      # piece_down takes care of finishing on hit
      break if piece_down
    end
  end

  # Move to the left
  def piece_left
    return unless @falling_piece

    @falling_piece.x -= @block_size
    @falling_piece.grid_position.x -= 1

    piece_right if collides?
  end

  # Move to the right
  def piece_right
    return unless @falling_piece

    @falling_piece.x += @block_size
    @falling_piece.grid_position.x += 1

    piece_left if collides?
  end

  # Rotate our piece
  def rotate_piece
    return unless @falling_piece

    # Now we need to see if the rotation caused a collision.
    # If so, unrotate it.
    rotate
    rotate_back if collides?
  end

  # Done with the piece, tell it to break apart into individual block actors, then
  # keep a reference to those blocks int he position they should be in
  def piece_finished
    blocks = build_blocks
    blocks.each do |block|
      @field[
        @falling_piece.grid_position.y + block.grid_offset_y
      ][
        @falling_piece.grid_position.x + block.grid_offset_x
      ] = block
    end

    new_piece
    check_row_removal
  end

  private

  # When the piece is done falling, build up block
  def build_blocks
    new_blocks = []
    current_rotated_blocks.each do |block|
      block_actor = @stage.create_actor :block,
                                        x: block[0] * BLOCK_SIZE + @falling_piece.x,
                                        y: block[1] * BLOCK_SIZE + @falling_piece.y,
                                        grid_offset_x: block[0],
                                        grid_offset_y: block[1],
                                        image: @falling_piece.image

      new_blocks << block_actor
    end
    # Destroy ourselves, leaving only the blocks behind
    @falling_piece.remove

    new_blocks
  end

  def current_rotated_blocks
    @falling_piece.blocks[@falling_piece.current_rotation]
  end

  def rotate
    @falling_piece.current_rotation = (@falling_piece.current_rotation + 1) % @falling_piece.blocks.length
  end

  # For undoing a rotation, for example in the case where a rotation causes a collision
  def rotate_back
    @falling_piece.current_rotation = (@falling_piece.current_rotation - 1) % @falling_piece.blocks.length
  end

  # Look for complete rows, and remove them
  def check_row_removal
    to_remove = []
    # First, we find all rows that need removing
    @field.each_with_index do |row, idx|
      # Ignore last row
      next if row == @field[-1]

      good = true
      row.each do |col|
        good = false if col.nil?
      end

      to_remove << idx if good
    end

    # Then we out the rows to remove
    to_remove.each do |row|
      @field[row].each_index do |col|
        @field[row][col].remove if @field[row][col] != 1
        @field[row][col] = nil
      end
    end

    # And finally move rows above nulled rows down to
    # collapse the field
    to_remove.each do |row|
      (1..row).to_a.reverse.each do |r|
        @field[r].length.times do |i|
          if @field[r-1][i].is_a?(Actor)
            @field[r][i] = @field[r-1][i]
            @field[r][i].y += BLOCK_SIZE
            @field[r-1][i] = nil
            @field[r][0] = 1
            @field[r][-1] = 1
          end
        end
      end
    end

    update_game_data(to_remove.length) if to_remove.length > 0
  end

  # Update game data like score and check to see
  # if we should progress to the next level
  def update_game_data(removing)
    if removing == 4
      @game_info.score += 1000
    else
      @game_info.score += 100 * removing
    end

    @line_count += removing
    if @line_count >= @tnl
      puts "Next level!"
      self.next_level
    end
  end

  def print_field
    puts "Field is currently: "
    @field.each do |col|
      col.each do |item|
        print "#{item.nil? ? "_" : "X"} "
      end
      print "\n"
    end
    puts @game_info.score if @game_info
  end

  def collides?
    hit = false
    current_rotated_blocks.each do |block|
      row = @falling_piece.grid_position.y + block[1]
      col = @falling_piece.grid_position.x + block[0]
      next if row < 0 # Don't collide up

      if !@field[row][col].nil?
        hit = true
        break
      end
    end

    hit
  end

  # Check blocks in the piece against the position in the field
  def collides_with_field?
  end

end
