require 'actor'
require 'actor_view'

class RockView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y
    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [5,25,15,255] 
  end
end


class Rock < Actor
  has_behaviors :physical => {:shape => :circle, 
    :mass => 40,
    :radius => 10}

  def setup
    @behaviors[:physical].body.a -= rand(10)
    @speed = rand(2)+1
  end

  def update(time)
    @behaviors[:physical].body.apply_impulse(@behaviors[:physical].body.rot*time*@speed, ZeroVec2) if @behaviors[:physical].body.v.length < 400
  end

end
