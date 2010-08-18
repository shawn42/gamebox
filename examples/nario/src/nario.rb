require 'numbers_ext'
require 'actor'
=begin
:bodies => [ # TODO make physical read multiple bodies
  :shape => :poly,
  :shapes => [
    :nario_feet => {:verts => [[-13,20],[-13,21],[13,21],[13,20]],:shape=>:poly, :offset => vec2(0,6)},
    :nario_hat => {:verts => [[-8,20],[-8,21],[8,21],[8,20]],:shape=>:poly, :offset => vec2(0,-46)}
    ],
  :mass => 150,
  :friction => 0.4,
  :moment => Float::INFINITY,
  :verts => [[-15,-20],[-15,20],[15,20],[15,-20]]},
],
=end
class Nario < Actor
  has_behaviors :audible,
    :physical => {
        :shape => :poly,
        :moment => Float::INFINITY,
        :shapes => [
          :nario_feet => {:verts => [[-13,20],[-13,21],[13,21],[13,20]],:shape=>:poly, :offset => vec2(0,6)},
          :nario_hat => {:verts => [[-8,20],[-8,21],[8,21],[8,20]],:shape=>:poly, :offset => vec2(0,-46)}
          ],
        :mass => 150,
        :friction => 0.4,
        :verts => [[-15,-20],[-15,20],[15,20],[15,-20]]},
    :layered => {:layer => 2, :parallax => 1},
    :animated => {:frame_update_time=>120},
    :collidable => {:shape => :circle, :radius => 20}

  # how long to apply the jump force for
  JUMP_TIME = 10

  attr_accessor :jump_timer
  def setup
    mass = nario_body.m
    @speed = mass * 0.6
    @jump_speed = 47*@speed
    @jump_timer = 0

    @max_speed = 399 #100
    @facing_dir = :right

    # TODO these will need to be updated if nario's speed changes
    @left_vec = vec2(-@speed,0)
    @right_vec = -@left_vec

    i = @input_manager
    i.reg :keyboard_down, KbUp do
      if !jumping? and grounded?
        play_sound :nario_jump
        @grounded = false
        @jump_timer = JUMP_TIME 
        self.action = "jump_#{@facing_dir}".to_sym
      end
    end
    i.reg :keyboard_down, KbLeft do
      @moving_left = true
      self.action = :move_left
    end
    i.reg :keyboard_down, KbRight do
      @moving_right = true
      self.action = :move_right
    end
    i.reg :keyboard_up, KbLeft do
      @moving_left = false
      idle
    end
    i.reg :keyboard_up, KbUp do
      idle
    end
    i.reg :keyboard_up, KbRight do
      @moving_right = false
      idle
    end
  end

  def moving_left?;@moving_left;end
  def moving_right?;@moving_right;end
  def jumping?;@jump_timer && @jump_timer > 0;end
  def grounded?;@grounded;end
  def update(time)
    move_left time if moving_left? and not jumping?
    move_right time if moving_right? and not jumping?
    jump time if jumping?
    super time
  end

  def idle
    self.action = "idle_#{@facing_dir}".to_sym
  end

  def stop_jump
    # this allows for "take off"
    unless @jump_timer == JUMP_TIME
      idle if jumping?
      @grounded = true
      @jump_timer = 0
    end
  end

  def nario_body
    physical.body
  end

  def jump(time)
    @jump_timer -= time
    @jump_timer = 0 if @jump_timer < 0

    nario_body.apply_impulse(vec2(0,-@jump_speed)*time, ZERO_VEC_2) if physical.body.v.length < @max_speed
  end

  def move_right(time)
    @facing_dir = :right
    force = grounded? ? @right_vec*2 : @right_vec
    nario_body.apply_impulse(force*time, ZERO_VEC_2) if physical.body.v.length < @max_speed
  end

  def move_left(time)
    @facing_dir = :left
    force = grounded? ? @left_vec*2 : @left_vec
    nario_body.apply_impulse(force*time, ZERO_VEC_2) if physical.body.v.length < @max_speed
  end
  
  def debug
    "x:#{self.x} y:#{self.y} jt:#{@jump_timer} g?:#{@grounded}"
  end
  
  def dying?
    @dying
  end

  def die
    @dying = true
    puts "You Died!"
    play_sound :nario_death
  end

end
