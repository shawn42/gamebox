require 'actor'
require 'animated_actor_view'

class NarioView < AnimatedActorView
  def draw(target)
    x = @actor.x
    y = @actor.y
#    bb = @actor.shape.bb
#    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [240,45,45,255]

    img = @actor.image
    deg = (@actor.deg.floor+90) % 360
    img = img.rotozoom(deg,1,true)

    w,h = *img.size
    x = x-w/2
    y = y-h/2
    img.blit target.screen, [x,y]
  end
end

class Nario < Actor
  has_behaviors :animated, :physical => {:shape => :poly, 
    :mass => 100,
    :verts => [[0,0],[0,20],[40,20],[40,0]]}

  def setup
    mass = self.body.mass
    @speed = mass * 0.02
    @jump_speed = -300*@speed
    @max_speed = 100
    @facing_dir = :right

    i = @input_manager
    i.reg KeyDownEvent, K_UP do
      jump
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
  def update(time)
    move_left time if moving_left?
    move_right time if moving_right?
    super time
  end


  # TODO add collision detection w/ ground for end of jump
  # animation
  def idle
    self.action = "idle_#{@facing_dir}".to_sym
  end

  def jump
    physical.body.apply_impulse(vec2(0,@jump_speed), ZeroVec2) if physical.body.v.length < @max_speed
    self.action = "jump_#{@facing_dir}".to_sym
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
