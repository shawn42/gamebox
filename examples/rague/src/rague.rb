require 'actor'
require 'actor_view'

class RagueView < ActorView
  def draw(target, x_off, y_off)
    target.draw_box [x_off+@actor.x,y_off+@actor.y], [x_off+@actor.x+30,y_off+@actor.y+30], [240,45,45,255]
  end
end

class Rague< Actor

  def setup

    i = input_manager
    i.reg KeyDownEvent, K_RIGHT do
      fire :move_right
    end
    i.reg KeyDownEvent, K_LEFT do
      fire :move_left
    end
    i.reg KeyDownEvent, K_UP do
      fire :move_up
    end
    i.reg KeyDownEvent, K_DOWN do
      fire :move_down
    end
    
    i.reg KeyDownEvent, K_SPACE do
      fire :change_location
    end
  end

  def update(time)
  end
end
