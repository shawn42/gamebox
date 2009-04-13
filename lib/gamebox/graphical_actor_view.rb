require 'actor_view'

class GraphicalActorView < ActorView
  def draw(target, x_off, y_off)
    x = @actor.x
    y = @actor.y

    img = @actor.image

    img.blit target.screen, [x+x_off,y+y_off]
  end
end
