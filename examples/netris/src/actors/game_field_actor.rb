define_actor :game_field do
  has_behavior :game_field, :positioned

  view do
    draw do |target, x_off, y_off, z|
      x1 = actor.x - 1 + x_off
      x2 = x1 + actor.grid.width + 1 + x_off

      y1 = actor.y - 1 + y_off
      y2 = y1 + actor.grid.height + 1 + y_off

      # Draw box
      target.draw_box( x1, y1, x2, y2, [255,255,255,255], 0 )

      # But hide the top line
      target.draw_line(x1, y1, x2, y1, [0, 0, 0, 255], 0)
    end
  end

end
