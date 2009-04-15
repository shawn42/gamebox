require 'actor'
require 'animated_actor_view'

class Rock < Actor
  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 200,
    :radius => 20}

  def setup
    @behaviors[:physical].body.a -= rand(10)
    @speed = (rand(2)+1)/4.0
    @turn_speed = rand(2)*0.00004
    @dir = vec2(rand-0.5,rand-0.5)
  end

  def update(time)
    physical.body.w += time*@turn_speed
    physical.body.apply_impulse(@dir*time*@speed, ZeroVec2) if physical.body.v.length < 400
    super time
  end

end
