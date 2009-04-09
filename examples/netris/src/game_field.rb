require 'actor'
require 'actor_view'
require 'tetromino'

class GameFieldView < ActorView
  def draw(target)
    target.draw_box [@actor.x,@actor.y], [240,480], [255,255,255,255]
  end
end

class GameField < Actor

  TETROMINOS = [:square, :j, :l, :bar, :t, :s, :z]

  def setup
    @tetrominos = [:square]
    @current_speed = 40

    i = @input_manager
    i.reg KeyDownEvent, K_SPACE do
      next_tetromino
    end
  end

  def next_tetromino 
    type = TETROMINOS[rand(TETROMINOS.length)]
    @current_block = spawn type
    @current_block.x = self.x + rand(240)
    @current_block.y = self.y + rand(480)
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
