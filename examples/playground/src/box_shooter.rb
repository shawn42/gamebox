require 'actor'

class BoxShooter < Actor

  has_behaviors :updatable

  def setup
    @last_shot = 4000

    i = @input_manager
    i.reg KeyPressed, :space do
      spawn :clicky, :x => @mouse_x, :y => @mouse_y
    end

    i.reg MouseMotionEvent do |evt|
      @mouse_x = evt.pos[0]
      @mouse_y = evt.pos[1]
    end
  end

  def update(delta)
#    if @last_shot > 500 
#      @last_shot = 0
#      shoot_box
#    end
#
#    @last_shot += delta
  end

  def shoot_box
    box = spawn :box, :x => @x, :y => @y
    box.body.apply_impulse vec2(500, -700), ZeroVec2
    box.shape.e = 1.0
    box.shape.u = 0.0
  end

end
