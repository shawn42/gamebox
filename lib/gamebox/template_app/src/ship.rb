require 'actor'
require 'actor_view'
require 'publisher'

class ShipView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y

    img = @actor.image
    deg = @actor.deg.floor % 360
    img = img.rotozoom(deg,1,true)

    w,h = *img.size
    x = x-w/2
    y = y-h/2
    img.blit target.screen, [x,y]
  end

end

class Ship < Actor

  can_fire :shoot

  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 500,
    :radius => 10}
  attr_accessor :moving_forward, :moving_back,
    :moving_left, :moving_right

  def setup
    @speed = 1.1
    @turn_speed = 0.0045

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
      self.action = :thrust
    end
    i.reg KeyUpEvent, K_LEFT do
      @moving_left = false
    end
    i.reg KeyUpEvent, K_RIGHT do
      @moving_right = false
    end
    i.reg KeyUpEvent, K_UP do
      @moving_forward = false
      self.action = :idle
    end
  end

  def moving_forward?;@moving_forward;end
  def moving_left?;@moving_left;end
  def moving_right?;@moving_right;end
  def update(time)
    move_forward time if moving_forward?
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
  def move_forward(time)
    physical.body.apply_impulse(physical.body.rot*time*@speed, ZeroVec2) if physical.body.v.length < 400
  end
end
