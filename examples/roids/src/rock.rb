require 'actor'
require 'animated_actor_view'

class Rock < Actor
  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 200,
    :radius => 20}

  def setup
    @behaviors[:physical].body.a -= rand(10)
    @speed = (rand(2)+1) * 85
    @turn_speed = rand(2)*0.0004 
    @dir = vec2(rand-0.5,rand-0.5)
  end

  def update(time)
    physical.body.w += time*@turn_speed
    move_vec = @dir*time*@speed
#    if (move_vec + physical.body.v).length < 400
      physical.body.apply_impulse(move_vec, ZeroVec2) 
#    end
    super time
  end

end
