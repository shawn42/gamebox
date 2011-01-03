

class Bullet < Actor
  has_behaviors :animated, :updatable, :physical => {:shape => :circle, 
    :mass => 10,
    :radius => 3}

  attr_accessor :dir

  def setup
    @speed = 500
    # bullets live for 1/2 second
    @power = 500
  end

  def update(time)
    @power -= time
    if @power <= 0
      remove_self
    end
    physical.body.apply_impulse(@dir*time*@speed, ZERO_VEC_2) if physical.body.v.length < 400
    super time
  end

end
