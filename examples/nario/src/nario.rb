require 'actor'

class Nario < Actor
  has_behaviors :animated, 
    :physical => {
        :shape => :poly, 
        # :parts => [:nario_feet => [0,22],:nario_hat => [0,-22]],
        :parts => [
          :nario_feet => {:verts => [[-8,20],[-8,21],[8,21],[8,20]],:shape=>:poly, :offset => vec2(0,22)},
          :nario_hat => {:verts => [[-8,20],[-8,21],[8,21],[8,20]],:shape=>:poly, :offset => vec2(0,-32)}
          ],
        :mass => 70,
        :moment => Float::Infinity,
        :verts => [[-17,-20],[-17,20],[17,20],[17,-20]]},
    :layered => {:layer => 2, :parallax => 1}

  # how long to apply the jump force for
  JUMP_TIME = 10

  attr_accessor :jump_timer
  def setup
    mass = nario_body.mass
    @speed = mass * 2
    @jump_speed = 7*@speed
    @jump_timer = 0

    @max_speed = 399 #100
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
    physical.body
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
