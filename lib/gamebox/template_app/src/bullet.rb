require 'actor'
require 'actor_view'

class BulletView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y
    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [5,25,15,255] 
  end
end


class Bullet < Actor
  has_behaviors :physical => {:shape => :circle, 
    :mass => 10,
    :radius => 5}

  attr_accessor :dir
  can_fire :kill_me

  def setup
    @speed = 1
    # bullets live for 1 second
    @power = 1000
  end

  def update(time)
    @power -= time
    if @power <= 0
      fire :kill_me
    end
    physical.body.apply_impulse(@dir*time*@speed, ZeroVec2) if physical.body.v.length < 400
  end

end
