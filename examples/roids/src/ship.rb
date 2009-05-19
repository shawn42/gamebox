require 'actor'
require 'publisher'
require 'graphical_actor_view'

class ShipView < GraphicalActorView
  def draw(target, x_off, y_off)
    # draw a shield
    if @actor.invincible?
      x = @actor.x + x_off
      y = @actor.y + y_off

      target.draw_circle [x,y], 25, [200,200,255,140]
    end
    super target, x_off, y_off
  end
end

class Ship < Actor

  can_fire :shoot

  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 100,
    :friction => 1.7,
    :radius => 10}
  attr_accessor :moving_forward, :moving_back,
    :moving_left, :moving_right

  def setup
    @invincible_timer = 2000
    @speed = 300
    @turn_speed = 0.0045
    @max_speed = 500

    i = input_manager
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
  def invincible?
    @invincible_timer > 0
  end
  def update(time)
    if @invincible_timer > 0
      @invincible_timer -= time
    end
    move_forward time if moving_forward?
    move_left time if moving_left?
    move_right time if moving_right?
    enforce_limits time
    super time
  end

  def enforce_limits(time)
    physical.body.w -= 30 if physical.body.w > 2.5
    if physical.body.v.length > @max_speed
      physical.body.apply_impulse(-physical.body.v*time, ZeroVec2) 
    end
  end

  def shoot
    bullet = spawn :bullet
    bullet.warp vec2(self.x,self.y)+vec2(self.body.rot.x,self.body.rot.y).normalize*30
    bullet.body.a += self.body.a
    bullet.dir = vec2(self.body.rot.x,self.body.rot.y)
    play_sound :laser
  end

  def move_right(time)
    physical.body.a += time*@turn_speed
    if physical.body.w > 2.5
      physical.body.w += time*@turn_speed/5.0 
    end
  end
  def move_left(time)
    physical.body.a -= time*@turn_speed
    if physical.body.w > 2.5
      physical.body.w -= time*@turn_speed/5.0 
    end
  end
  def move_forward(time)
    move_vec = physical.body.rot*time*@speed
#    p move_vec
#    p physical.body.v
#    if (move_vec + physical.body.v).length < @max_speed
      physical.body.apply_impulse(move_vec, ZeroVec2) 

#    end
  end
end
