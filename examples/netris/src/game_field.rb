require 'actor'
require 'actor_view'

class GameFieldView < ActorView
  def draw(target)
    target.draw_box [@actor.x,@actor.y], [240,480], [255,255,255,255]
  end
end

class GameField < Actor

  def setup
    i = @input_manager
    i.reg KeyDownEvent, K_SPACE do
      fire :next_tetromino
    end
  end
end
