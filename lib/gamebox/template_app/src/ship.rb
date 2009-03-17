require 'actor'
require 'actor_view'
require 'publisher'

class ShipView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y
    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [50,250,150,255] 
  end
end


class Ship < Actor

  can_fire :shoot

  has_behaviors :physical => {:shape => :circle, 
    :mass => 40,
    :radius => 10}
  attr_accessor :moving_forward, :moving_back,
    :moving_left, :moving_right

  def setup
    @speed = 0.7
    @turn_speed = 0.003

    i = @input_manager
    i.reg KeyDownEvent, K_SPACE do
      shoot
    end
    i.reg KeyDownEvent, K_RCTRL, K_LCTRL do
      warp vec2(rand(400)+100,rand(400)+100)
    end
    i.reg KeyDownEvent, K_LEFT do
      @moving_left = true
    end
    i.reg KeyDownEvent, K_RIGHT do
      @moving_right = true
    end
    i.reg KeyDownEvent, K_UP do
      @moving_forward = true
    end
    i.reg KeyDownEvent, K_DOWN do
      @moving_back = true
    end
    i.reg KeyUpEvent, K_LEFT do
      @moving_left = false
    end
    i.reg KeyUpEvent, K_RIGHT do
      @moving_right = false
    end
    i.reg KeyUpEvent, K_UP do
      @moving_forward = false
    end
    i.reg KeyUpEvent, K_DOWN do
      @moving_back = false
    end
  end

  def moving_forward?;@moving_forward;end
  def moving_back?;@moving_back;end
  def moving_left?;@moving_left;end
  def moving_right?;@moving_right;end
  def update(time)
    move_forward time if moving_forward?
    move_back time if moving_back?
    move_left time if moving_left?
    move_right time if moving_right?
  end

  def shoot
    fire :shoot
  end

  def move_right(time)
    physical.body.a += time*@turn_speed
    physical.body.w += time*@turn_speed/5.0 if physical.body.w > 2.5
  end
  def move_left(time)
    physical.body.a -= time*@turn_speed
    physical.body.w -= time*@turn_speed/5.0 if physical.body.w > 2.5
  end
  def move_back(time)
    physical.body.apply_impulse(-physical.body.rot*time*@speed, ZeroVec2) if physical.body.v.length < 400
  end
  def move_forward(time)
    physical.body.apply_impulse(physical.body.rot*time*@speed, ZeroVec2) if physical.body.v.length < 400
  end
end
