require 'actor_view'

class GraphicalActorView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y

    img = @actor.image

    img.blit target.screen, [x,y]
  end
end
