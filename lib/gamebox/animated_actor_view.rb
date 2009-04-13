require 'actor_view'

class AnimatedActorView < ActorView
  def draw(target, x_off, y_off)
    x = @actor.x + x_off
    y = @actor.y + y_off

    img = @actor.image

    w,h = *img.size
    x = x-w/2
    y = y-h/2
    img.blit target.screen, [x,y]
  end
end
