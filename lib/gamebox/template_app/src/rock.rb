require 'actor'
require 'actor_view'

class RockView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y

    img = @actor.image
    deg = @actor.deg.floor % 360
    img = img.rotozoom(deg,1,true)

    w,h = *img.size
    x = x-w/2
    y = y-h/2
    img.blit target.screen, [x,y]
  end
end


class Rock < Actor
  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 200,
    :radius => 20}

  def setup
    @behaviors[:physical].body.a -= rand(10)
    @speed = (rand(2)+1)/4.0
#    @turn_speed = rand(2)*0.004
    @turn_speed = rand(2)*0.00004
    @dir = vec2(rand,rand)
  end

  def update(time)
    physical.body.w += time*@turn_speed
#    p physical.body.a
    physical.body.apply_impulse(@dir*time*@speed, ZeroVec2) if physical.body.v.length < 400
  end

end
