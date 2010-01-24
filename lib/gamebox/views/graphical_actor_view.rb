require 'actor_view'

class GraphicalActorView < ActorView
  def draw(target, x_off, y_off)
    x = @actor.x
    y = @actor.y

    offset_x = x+x_off
    offset_y = y+y_off

    img = @actor.image
    return if img.nil?

    #if @actor.is? :animated or 
    if @actor.is? :physical
      w,h = *img.size
      offset_x = x-w/2 + x_off
      offset_y = y-h/2 + y_off
      img.blit target.screen, [offset_x,offset_y]
    else
      graphical_behavior = @actor.graphical if @actor.is? :graphical
      if graphical_behavior && graphical_behavior.tiled?
        x_tiles = graphical_behavior.num_x_tiles
        y_tiles = graphical_behavior.num_y_tiles
        img_w, img_h = *img.size
        x_tiles.times do |col|
          y_tiles.times do |row|
            img.blit target.screen, [offset_x+col*img_w,offset_y+row*img_h]
          end
        end
      else
        img.blit target.screen, [offset_x,offset_y]
      end

    end
  end
end
