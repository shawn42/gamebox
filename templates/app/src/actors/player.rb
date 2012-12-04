define_actor :player do
  has_behavior :positioned
  view do
    draw do |target, x_off, y_off, z|
      x = actor.x + x_off
      y = actor.y + y_off
      target.draw_box x,y, x+20, y+20, Color::RED, 1
    end
  end
end
