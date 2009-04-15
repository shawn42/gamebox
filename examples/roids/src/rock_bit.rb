require 'actor'
require 'animated_actor_view'

class RockBit < Actor
  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 100,
    :radius => 10}

  def setup
    @behaviors[:physical].body.a -= rand(10)
    @speed = (rand(2)+1)/6.0
    @turn_speed = rand(2)*0.00004
    x = (rand-0.5) * 2
    y = (rand-0.5) * 2
    @dir = vec2(x,y)

    #bits only live for 500-1000
    @ttl = 500+rand(500)
  end

  def update(time)
    @ttl -= time
    remove_self if @ttl < 0
    physical.body.w += time*@turn_speed
    physical.body.apply_impulse(@dir*time*@speed, ZeroVec2) if physical.body.v.length < 400
    super time
  end

end
