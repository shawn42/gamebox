

class GraphicalActorView < ActorView
  def draw(target, x_off, y_off, z)
    x = actor.x
    y = actor.y

    offset_x = x+x_off
    offset_y = y+y_off

    img = actor.image
    return if img.nil?

    alpha = actor.respond_to?(:alpha) ? actor.alpha : 0xFF
    color = Color.new(alpha,0xFF,0xFF,0xFF)

    x_scale = actor.x_scale
    y_scale = actor.y_scale

    if actor.is? :physical
      img_w = img.width
      img_h = img.height

      img.draw_rot offset_x, offset_y, z, actor.rotation, 0.5, 0.5, x_scale, y_scale
    else
      graphical_behavior = actor.graphical if actor.is? :graphical
      if graphical_behavior && graphical_behavior.tiled?
        x_tiles = graphical_behavior.num_x_tiles
        y_tiles = graphical_behavior.num_y_tiles
        img_w = img.width
        img_h = img.height
        x_tiles.times do |col|
          y_tiles.times do |row|
            # TODO why is there a nasty black line between these that jitters?
            img.draw_rot offset_x+col*img_w, offset_y+row*img_h, z, actor.rotation, x_scale, y_scale
          end
        end
      else
        if actor.respond_to? :rotation
          rot = actor.rotation || 0.0
          img.draw_rot offset_x, offset_y, z, rot, 0.5, 0.5, x_scale, y_scale, color
        else
          img.draw offset_x, offset_y, z, x_scale, y_scale, color
        end
      end
    end
  end

end
