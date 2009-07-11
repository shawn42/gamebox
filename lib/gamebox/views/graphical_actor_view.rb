require 'actor_view'

class GraphicalActorView < ActorView
  def draw(target, x_off, y_off)
    debug = false
    x = @actor.x
    y = @actor.y
    img = @actor.image
    return if img.nil?

    #if @actor.is? :animated or 
    if @actor.is? :physical
      w,h = *img.size
      x = x-w/2
      y = y-h/2
      img.blit target.screen, [x+x_off,y+y_off]
      
      if @actor.is? :physical and debug
        @actor.physical.shapes.each do |shape|
          bb = shape.bb
          x = bb.l + x_off
          y = bb.b + y_off
          x2 = bb.r + x_off
          y2 = bb.t + y_off
          target.draw_box_s [x,y], [x2,y2], [255,25,25,150]
        end
      end
      
    else
      img.blit target.screen, [x+x_off,y+y_off]
    end
  end
end
