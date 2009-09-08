require 'actor'

class Rock < Actor
  has_behaviors :animated, :updatable, :physical => {:shape => :circle, 
    :mass => 10,
    :radius => 20}

  def setup
    @behaviors[:physical].body.a -= rand(10)
    @speed = (rand(2)+1) * 20
    @turn_speed = rand(2)*0.0004 
    @dir = vec2(rand-0.5,rand-0.5)
  end

  def update(time)
    physical.body.reset_forces

    physical.body.p = CP::Vec2.new(physical.body.p.x % 1024, physical.body.p.y % 768)
    physical.body.w += time*@turn_speed

    move_vec = @dir * time * @speed

    physical.body.apply_force(move_vec, ZERO_VEC_2) 

    super time
  end

end
