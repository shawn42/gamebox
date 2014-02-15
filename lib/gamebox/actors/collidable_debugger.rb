define_actor :collidable_debugger do
  has_behaviors :collider_container
end

define_behavior :collider_container do
  setup do
    raise "collider required" unless actor.do_or_do_not(:collider)
    actor.collider.when :remove do
      actor.remove
    end
  end
end

define_actor_view :collidable_debugger_view do

  setup do
    @color = actor.do_or_do_not(:color) || Color::WHITE
  end

  draw do |target,x_off,y_off,z|
    collider = actor.collider
    if collider.shape_type == :circle
      target.draw_circle x_off+collider.center_x, y_off+collider.center_y, collider.radius, @color, z
    else
      collider.cw_world_lines.each do |line|
        f = line.first
        l = line.last
        target.draw_line x_off+f[0],y_off+f[1],x_off+l[0],y_off+l[1], @color, z
      end
    end
  end
end
