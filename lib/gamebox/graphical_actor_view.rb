require 'actor_view'

class GraphicalActorView < ActorView
  def draw(target, x_off, y_off)
    x = @actor.x
    y = @actor.y
    img = @actor.image

    if @actor.is? :animated or @actor.is? :physical
      w,h = *img.size
      x = x-w/2
      y = y-h/2
      img.blit target.screen, [x,y]
    else
      img.blit target.screen, [x+x_off,y+y_off]
    end
  end
end
