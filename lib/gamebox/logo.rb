require 'actor'
require 'graphical_actor_view'
class LogoView < GraphicalActorView
  def draw(target,xoff,yoff)
    super target, 0, 0
  end
end
class Logo < Actor
  has_behaviors :graphical, 
  :layered => {:layer => 999}
end
