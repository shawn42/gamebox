require 'actor'
require 'actor_view'

class BulletView < ActorView
  def draw(target)
#    caller.each do |c|
#      p c
#    end

    x = @actor.x
    y = @actor.y

    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [5,25,205,155] 

    img = @actor.image
    deg = @actor.deg.floor % 360
    img = img.rotozoom(deg,1,true)

    w,h = *img.size
    x = x-w/2
    y = y-h/2
    img.blit target.screen, [x,y]
  end
end


class Bullet < Actor
  has_behaviors :animated, :physical => {:shape => :circle, 
    :mass => 90,
    :radius => 3}

  attr_accessor :dir

  def setup
    @speed = 1
    # bullets live for 1 second
    @power = 1000
  end

  def update(time)
    @power -= time
    if @power <= 0
      remove_self
    end
    physical.body.apply_impulse(@dir*time*@speed, ZeroVec2) if physical.body.v.length < 400
  end

end
