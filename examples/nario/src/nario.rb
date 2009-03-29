require 'actor'
require 'actor_view'

class NarioView < ActorView
  def draw(target)
    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [240,45,45,255]
  end
end

class Nario < Actor
  has_behaviors :physical => {:shape => :poly, 
    :mass => 100,
    :verts => [[0,0],[0,20],[40,20],[40,0]]}

  def setup
    mass = self.body.mass
    @speed = mass * 0.002
    @jump_speed = -300*@speed
    @max_speed = 100

    i = @input_manager
    i.reg KeyDownEvent, K_UP do
      jump
    end
    i.reg KeyDownEvent, K_LEFT do
      @moving_left = true
    end
    i.reg KeyDownEvent, K_RIGHT do
      @moving_right = true
    end
    i.reg KeyUpEvent, K_LEFT do
      @moving_left = false
    end
    i.reg KeyUpEvent, K_RIGHT do
      @moving_right = false
    end
  end

  def moving_left?;@moving_left;end
  def moving_right?;@moving_right;end
  def update(time)
    move_left time if moving_left?
    move_right time if moving_right?
    super time
  end

  def jump
    physical.body.apply_impulse(vec2(0,@jump_speed), ZeroVec2) if physical.body.v.length < @max_speed
  end

  def move_right(time)
    physical.body.apply_impulse(vec2(@speed,0)*time, ZeroVec2) if physical.body.v.length < @max_speed
  end

  def move_left(time)
    # TODO cache these vectors
    physical.body.apply_impulse(vec2(-@speed,0)*time, ZeroVec2) if physical.body.v.length < @max_speed
  end


end
