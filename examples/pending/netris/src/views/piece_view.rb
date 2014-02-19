define_actor_view :piece_view do
  draw do |target, x_off, y_off, z|
    image = actor.do_or_do_not(:image)
    if image
      actor.blocks[actor.current_rotation].each do |b|
        x = (BLOCK_SIZE * b[0]) + actor.x + x_off
        y = (BLOCK_SIZE * b[1]) + actor.y + x_off
        target.draw_image actor.image, x, y, 0
      end
    end
  end
end
