require 'actor'
require 'actor_view'

class NarioHatView < ActorView
  def draw(target, x_off, y_off)
    bb = @actor.shape.bb
    x = bb.l + x_off
    y = bb.b + y_off
    x2 = bb.r + x_off
    y2 = bb.t + y_off
    target.draw_box [x,y], [x2,y2], [255,25,25,255]
    target.draw_circle_s [@actor.x+x_off,@actor.y+y_off], 1, [25,25,255,255]
  end
end

class NarioView < NarioHatView
  def draw(target, x_off, y_off)
    bb = @actor.shape.bb
    x = bb.l + x_off
    y = bb.b + y_off
    x2 = bb.r + x_off
    y2 = bb.t + y_off
    target.draw_box [x,y], [x2,y2], [255,255,255,255]
    target.draw_circle_s [@actor.x+x_off,@actor.y+y_off], 1, [255,255,255,255]
  end
end

class NarioFeetView < NarioHatView
  def draw(target, x_off, y_off)
    bb = @actor.shape.bb
    x = bb.l + x_off
    y = bb.b + y_off
    x2 = bb.r + x_off
    y2 = bb.t + y_off
    target.draw_box [x,y], [x2,y2], [25,255,25,255]
    target.draw_circle_s [@actor.x+x_off,@actor.y+y_off], 1, [25,255,25,255]
  end
end

class NarioHat < Actor
  has_behaviors :physical => {
    :shape => :poly, 
    :mass => 20,
    :moment => Float::Infinity,
    :verts => [[-8,20],[-8,21],[8,21],[8,20]]},
    :layered => {:layer => 2, :parallax => 2}
end


# TODO why can't I subclass NarioHat for his physics
class NarioFeet < Actor
  has_behaviors :physical => {
    :shape => :poly, 
    :mass => 100,
    :moment => Float::Infinity,
    :verts => [[-8,20],[-8,21],[8,21],[8,20]]},
    :layered => {:layer => 2, :parallax => 2}
end

class Nario < Actor
  has_behaviors :animated, 
    :physical => {
        :shape => :poly, 
        :parts => [:nario_feet => [0,22],:nario_hat => [0,-22]],
#        :parts => [:nario_feet => [0,22]],
#        :parts => [:nario_hat => [0,-22]],
        :mass => 70,
        :moment => Float::Infinity,
        :verts => [[-17,-20],[-17,20],[17,20],[17,-20]]},
    :layered => {:layer => 2, :parallax => 2}

  # how long to apply the jump force for
  JUMP_TIME = 10

  attr_accessor :jump_timer
  def setup
    mass = nario_body.mass
    @speed = mass * 2.5
    @jump_speed = 7*@speed
    @jump_timer = 0

    @max_speed = 299 #100
    @facing_dir = :right

    # TODO these will need to be updated if nario's speed changes
    @left_vec = vec2(-@speed,0)
    @right_vec = -@left_vec

    i = @input_manager
    i.reg KeyDownEvent, K_UP do
      if !jumping? and grounded?
        @grouned = false
        @jump_timer = JUMP_TIME 
        self.action = "jump_#{@facing_dir}".to_sym
      end
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
  def grounded?;@grounded;end
  def update(time)
#    p self.y
    move_left time if moving_left?
    move_right time if moving_right?
    jump time if jumping?
    super time
  end

  def idle
    self.action = "idle_#{@facing_dir}".to_sym
  end

  def stop_jump
    # this allows for "take off"
    unless @jump_timer == JUMP_TIME
      @grounded = true
      @jump_timer = 0
    end
  end

  def nario_body
    # apply force to feet instead?
    if physical.parts[:nario_feet]
       physical.parts[:nario_feet].body 
    else
      physical.body
    end
  end

  def jump(time)
    @jump_timer -= time

    nario_body.apply_impulse(vec2(0,-@jump_speed)*time, ZeroVec2) if physical.body.v.length < @max_speed
  end

  def move_right(time)
    @facing_dir = :right
    nario_body.apply_impulse(@right_vec*time, ZeroVec2) if physical.body.v.length < @max_speed
  end

  def move_left(time)
    @facing_dir = :left
    nario_body.apply_impulse(@left_vec*time, ZeroVec2) if physical.body.v.length < @max_speed
  end


end
