define_actor :block do
  has_behavior :positioned
  has_attributes  image: nil,
                  grid_offset_x: nil,
                  grid_offset_y: nil

  view do
    draw do |target, x_off, y_off, z|
      x = actor.x + x_off
      y = actor.y + x_off
      target.draw_image actor.image, x, y, 0
    end
  end
end
