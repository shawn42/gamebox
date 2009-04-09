require 'actor'
require 'actor_view'
require 'tetromino'
require 'grid'

class GameFieldView < ActorView
  def draw(target)
    target.draw_box [@actor.x,@actor.y], [@actor.grid.width,@actor.grid.height], [255,255,255,255]
  end
end

class GameField < Actor

  attr_accessor :grid

  TETROMINOS = [:square, :j, :l, :bar, :t, :s, :z]

  def setup
    @tetrominos = [:square]
    @current_speed = 80
    @grid = Grid.new(10, 20)

    i = @input_manager
    i.reg KeyDownEvent, K_SPACE do
      next_tetromino
    end
  end

  def next_tetromino 
    type = TETROMINOS[rand(TETROMINOS.length)]
    @current_block = spawn type
    grid_x, grid_y = @grid.new_piece_coords
    @current_block.x = self.x + grid_x
    @current_block.y = self.y + grid_y
  end

  def update(time)
    if @current_block
      @current_block.y += @current_speed * (time/1000.0)

      if @current_block.y > (480 - 24)
        next_tetromino
      end
    end

    super
  end

end
