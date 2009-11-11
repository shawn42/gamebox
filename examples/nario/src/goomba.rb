require 'actor'

class Goomba < Actor
  has_behaviors :animated, :updatable, 
    :physical => {
        :shape => :poly,
        :mass => 200,
        :friction => 0.8,
        :moment => Float::INFINITY,
        :verts => [[-17,-16],[-17,14],[17,14],[17,-16]]},
    :layered => {:layer => 2, :parallax => 1}

  def setup
    mass = goomba_body.m
    @speed = mass * 0.6

    @max_speed = 299

    # TODO these will need to be updated if nario's speed changes
    @left_vec = vec2(-@speed,0)
    @right_vec = -@left_vec

    @direction = :left
    self.action = :walking
  end

  def update(time)
    # 5% chance to change directions
    change_dir = (rand(20) == 1)
    
    case @direction
    when :left
      if change_dir
        @direction = :right
      else
        move_left time
      end
    when :right
      if change_dir
        @direction = :left
      else
        move_right time
      end
    end
    
    super time
  end

  def goomba_body
    physical.body
  end

  def move_right(time)
    goomba_body.apply_impulse(@right_vec*time, ZERO_VEC_2) if physical.body.v.length < @max_speed
  end

  def move_left(time)
    goomba_body.apply_impulse(@left_vec*time, ZERO_VEC_2) if physical.body.v.length < @max_speed
  end
  
  def debug
    "x:#{self.x} y:#{self.y}"
  end
  
  def dying?
    @dying
  end
  
  def die
    puts "Goomba death"
    @dying = true
    remove_self
    # play_sound :goomba_squish
  end

end
