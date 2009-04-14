require 'actor'
require 'actor_view'

class MyActorView < ActorView
  def draw(target, x_off, y_off)
    target.draw_box [@actor.x,@actor.y], [20,20], [240,45,45,255]
  end
end

class MyActor < Actor

  def setup
    # TODO setup stuff here
    # subscribe for an event or something?
  end

end
