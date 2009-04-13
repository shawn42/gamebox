require 'actor'
require 'animated_actor_view'

class Bullet < Actor
  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 90,
    :radius => 3}

  attr_accessor :dir

  def setup
    @speed = 1
    # bullets live for 1/2 second
    @power = 500
  end

  def update(time)
    @power -= time
    if @power <= 0
      remove_self
    end
    physical.body.apply_impulse(@dir*time*@speed, ZeroVec2) if physical.body.v.length < 400
    super time
  end

end
