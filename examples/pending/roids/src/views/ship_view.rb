# TODO can this be composed of another view? this view draws the shield the GAV draws the ship?
# subview helper or something?
define_actor_view :ship_view do

  draw do |target, x_off, y_off, z|
    x = actor.x
    y = actor.y
    offset_x = x+x_off
    offset_y = y+y_off

    # draw a shield
    if actor.invincible
      radius = 25
      target.draw_circle offset_x, offset_y, radius, [200,200,255,140], z
    end
    # COPY PASTE FROM :graphical_actor_view

    img = actor.do_or_do_not(:image)
    return if img.nil?

    alpha = actor.do_or_do_not(:alpha) || 0xFF
    color = Color.new(alpha,0xFF,0xFF,0xFF)

    x_scale = actor.do_or_do_not(:x_scale) || 1
    y_scale = actor.do_or_do_not(:y_scale) || 1

    if actor.respond_to? :rotation
      rot = actor.rotation || 0.0
      img.draw_rot offset_x, offset_y, z, rot, 0.5, 0.5, x_scale, y_scale, color
    else
      img.draw offset_x, offset_y, z, x_scale, y_scale, color
    end
  end
end

