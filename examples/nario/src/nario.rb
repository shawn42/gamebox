require 'actor'
require 'actor_view'

class NarioHatView < ActorView
  def draw(target, x_off, y_off)
    bb = @actor.shape.bb
    x = bb.l + x_off
    y = bb.b + y_off
    x2 = bb.r + x_off
    y2 = bb.t + y_off
    target.draw_box_s [x,y], [x2,y2], [255,25,25,255]
  end
end

class NarioHat < Actor
  has_behaviors :physical => {
    :shape => :poly, 
    :mass => 10,
    :moment => Float::Infinity,
    :verts => [[-8,20],[-8,21],[8,21],[8,20]]},
    :layered => {:layer => 2, :parallax => 2}
end

class NarioFeetView < NarioHatView
end

# TODO why can't I subclass NarioHat for his physics
class NarioFeet < Actor
  has_behaviors :physical => {
    :shape => :poly, 
    :mass => 25,
    :moment => Float::Infinity,
    :verts => [[-8,20],[-8,21],[8,21],[8,20]]},
    :layered => {:layer => 2, :parallax => 2}
end

class Nario < Actor
  has_behaviors :animated, 
    :physical => {
        :shape => :poly, 
        :parts => [:nario_feet => [0,5],:nario_hat => [0,-65]],
        :mass => 75,
        :moment => Float::Infinity,
        :verts => [[-17,-20],[-17,20],[17,20],[17,-20]]},
    :layered => {:layer => 2, :parallax => 2}

  # how long to apply the jump force for
  JUMP_TIME = 200

  def setup
    mass = self.body.mass
    @speed = mass * 0.02
#    @jump_speed = 4*@speed
    @jump_speed = 8*@speed
    @jump_timer = 0

    @max_speed = 100
    @facing_dir = :right

    i = @input_manager
    i.reg KeyDownEvent, K_UP do
      @jump_timer = JUMP_TIME
      self.action = "jump_#{@facing_dir}".to_sym
    end
    i.reg KeyDownEvent, K_LEFT do
      @moving_left = true
      self.action = :move_left
    end
    i.reg KeyDownEvent, K_RIGHT do
      @moving_right = true
      self.action = :move_right
    end
    i.reg KeyUpEvent, K_LEFT do
      @moving_left = false
      idle
    end
    i.reg KeyUpEvent, K_RIGHT do
      @moving_right = false
      idle
    end
  end

  def moving_left?;@moving_left;end
  def moving_right?;@moving_right;end
  def jumping?;@jump_timer > 0;end
  def update(time)
    move_left time if moving_left?
    move_right time if moving_right?
    jump time if jumping?
    super time
  end


  # TODO add collision detection w/ ground for end of jump
  # animation
  def idle
    self.action = "idle_#{@facing_dir}".to_sym
  end

  def stop_jump
    @jump_timer = 0
  end

  def jump(time)
    @jump_timer -= time
    physical.body.apply_impulse(vec2(0,-@jump_speed)*time, ZeroVec2) if physical.body.v.length < @max_speed
  end

  def move_right(time)
    @facing_dir = :right
    # TODO cache these vectors
    physical.body.apply_impulse(vec2(@speed,0)*time, ZeroVec2) if physical.body.v.length < @max_speed
  end

  def move_left(time)
    @facing_dir = :left
    physical.body.apply_impulse(vec2(-@speed,0)*time, ZeroVec2) if physical.body.v.length < @max_speed
  end


end
