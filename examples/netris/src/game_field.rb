require 'actor'
require 'actor_view'
require 'tetromino'
require 'grid'

class GameFieldView < ActorView
  def draw(target)
    x1 = @actor.x - 1
    x2 = x1 + @actor.grid.width + 1

    y1 = @actor.y - 1
    y2 = y1 + @actor.grid.height + 1
    target.draw_box( [x1, y1], [x2, y2], [255,255,255,255] )
  end
end

class GameField < Actor

  attr_accessor :grid

  TETROMINOS = [:square, :j, :l, :bar, :t, :s, :z]

  def setup
    # Drop a row every x milliseconds
    @drop_after = 500

    @grid = Grid.new(10, 20)
    i = @input_manager
    i.reg KeyDownEvent, K_N do
      next_tetromino
    end

    i.reg KeyDownEvent, K_SPACE do
      @grid.drop_piece
      next_tetromino
    end

    i.reg KeyDownEvent, K_LEFT do
      @grid.piece_left
    end

    i.reg KeyDownEvent, K_RIGHT do
      @grid.piece_right
    end

    @time_lapsed = 0
  end

  def next_tetromino 
    @grid.screen_x = self.x
    @grid.screen_y = self.y

    type = TETROMINOS[rand(TETROMINOS.length)]
    @current_block = spawn type
    @grid.new_piece @current_block
  end

  def update(time)
    if @current_block
      @time_lapsed += time

      if @time_lapsed >= @drop_after
        if @grid.piece_down
          next_tetromino
        end

        @time_lapsed = 0
      end
    end

    super
  end

end
