
require 'publisher'
require 'graphical_actor_view'

class ShipView < GraphicalActorView
  def draw(target, x_off, y_off, z)
    # draw a shield
    if @actor.invincible?
      radius = 25
      x = @actor.x + x_off - radius
      y = @actor.y + y_off - radius

      target.draw_circle x,y, radius, [200,200,255,140], z
    end
    super target, x_off, y_off, z
  end
end

class Ship < Actor

  can_fire :shoot

  has_behavior :audible, :animated, :updatable, :physical => {:shape => :circle, 
    :mass => 10,
    :friction => 1.7,
    :elasticity => 0.4,
    :radius => 10,
    :moment => 150 
  }
  attr_accessor :moving_forward, :moving_back,
    :moving_left, :moving_right

  def setup
    @invincible_timer = 2000
    @speed = 300
    @turn_speed = 0.0045
    @max_speed = 500

    i = input_manager
    i.reg :keyboard_down, KbSpace do
      shoot
    end
    i.reg :keyboard_down, KbRightControl, KbLeftControl do
      warp vec2(rand(400)+100,rand(400)+100)
    end
    i.reg :keyboard_down, KbLeft do
      @moving_left = true
    end
    i.reg :keyboard_down, KbRight do
      @moving_right = true
    end
    i.reg :keyboard_down, KbUp do
      @moving_forward = true
      self.action = :thrust
    end
    i.reg :keyboard_up, KbLeft do
      @moving_left = false
    end
    i.reg :keyboard_up, KbRight do
      @moving_right = false
    end
    i.reg :keyboard_up, KbUp do
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
    physical.body.reset_forces
    move_forward time if moving_forward?
    move_left time if moving_left?
    move_right time if moving_right?
    physical.body.p = CP::Vec2.new(physical.body.p.x % 1024, physical.body.p.y % 768)
    super time
  end

  def shoot
    bullet = spawn :bullet
    bullet.warp vec2(self.x,self.y)+vec2(self.body.rot.x,self.body.rot.y).normalize*30
    bullet.body.a += self.body.a
    bullet.dir = vec2(self.body.rot.x,self.body.rot.y)
    play_sound :laser
  end

  def move_right(time)
    physical.body.t += 100.0 * time
  end

  def move_left(time)
    physical.body.t -= 100.0 * time
  end

  def move_forward(time)
    val = physical.body.a
    move_vec = CP::Vec2.new(Math::cos(val), Math::sin(val)) * time * @speed

    physical.body.apply_force(move_vec, ZERO_VEC_2) 
  end
end
