require 'actor'
require 'actor_view'

# unfortunately, we need a custom view because rubygame's
# rotozoom resizes the image
class PrettyGemView < ActorView
  def draw(target, x_off, y_off)
    x = @actor.x
    y = @actor.y

    rot = @actor.rotation

    img = @actor.image.rotozoom rot, 1, true
    w,h = *img.size
    x = x-w/2 + @actor.orig_w
    y = y-h/2 + @actor.orig_w
    img.blit target.screen, [x+x_off,y+y_off]
  end
end

class PrettyGem < Actor
  has_behavior :graphical, :dancing, :updatable, :layered => {:layer => 3}
end
