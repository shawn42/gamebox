define_actor :l do
  has_behavior :positioned
  has_attributes  image: nil,
                  blocks: [ [
                      [0 , 0],
                      [0,-1],
                      [-1, 0],
                      [-2, 0]
                    ], [
                      [0 , 0],
                      [1, 0],
                      [0, -1],
                      [0, -2]
                    ], [
                      [0 , 0],
                      [1, 0],
                      [2, 0],
                      [0, 1]
                    ], [
                      [0 , 0],
                      [-1, 0],
                      [0, 1],
                      [0, 2]
                    ]],
                  current_rotation: 0,
                  grid_position: Struct.new(:x, :y).new(0, 0)

  view do
    draw do |target, x_off, y_off, z|
      actor.blocks[actor.current_rotation].each do |b|
        x = (BLOCK_SIZE * b[0]) + actor.x + x_off
        y = (BLOCK_SIZE * b[1]) + actor.y + x_off
        target.draw_image actor.image, x, y, 0
      end
    end

    setup do
      actor.image = resource_manager.load_image("orange.png")
    end
  end
end
