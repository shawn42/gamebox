require 'actor_view'

class AnimatedActorView < ActorView
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
