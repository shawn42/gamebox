define_actor :player do
  has_behavior :positioned
  view do
    draw do |target, x_off, y_off, z|
      target.draw_box actor.x,actor.y, 20, 20, Color::RED, 1
    end
  end
end
