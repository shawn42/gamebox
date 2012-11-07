
define_actor_view :graphical_actor_view do

  draw do |target, x_off, y_off, z|
    img = actor.do_or_do_not(:image)
    return if img.nil?

    x = actor.x
    y = actor.y

    offset_x = x+x_off
    offset_y = y+y_off

    alpha = actor.do_or_do_not(:alpha) || 0xFF
    color = Color.new(alpha,0xFF,0xFF,0xFF)

    x_scale = actor.do_or_do_not(:x_scale) || 1
    y_scale = actor.do_or_do_not(:y_scale) || 1

    if actor.do_or_do_not(:tiled)
      x_tiles = actor.num_x_tiles
      y_tiles = actor.num_y_tiles
      img_w = img.width
      img_h = img.height
      x_tiles.times do |col|
        y_tiles.times do |row|
          # TODO why is there a nasty black line between these that jitters?
          img.draw offset_x+col*img_w, offset_y+row*img_h, z, x_scale, y_scale
        end
      end
    else
      rot = actor.do_or_do_not :rotation
      if rot
        img.draw_rot offset_x, offset_y, z, rot, 0.5, 0.5, x_scale, y_scale, color
      else
        img.draw offset_x, offset_y, z, x_scale, y_scale, color
      end
    end
  end

end
