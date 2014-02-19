define_actor :block do
  has_behavior :positioned

  view do
    draw do |target, x_off, y_off, z|
      image = actor.do_or_do_not(:image)
      x = actor.x + x_off
      y = actor.y + x_off
      target.draw_image image, x, y, z if image
    end
  end
end
