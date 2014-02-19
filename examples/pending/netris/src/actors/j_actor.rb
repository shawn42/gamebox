define_actor :j do
  has_behaviors do
    positioned
    colored color: 'dark_blue.png'
  end
  has_attributes  blocks: [
                    [[0 , 0],[0,-1],[1, 0],[2, 0]],
                    [[0 , 0],[1, 0],[0, 1],[0, 2]],
                    [[0 , 0],[-1, 0],[-2, 0],[0, 1]],
                    [[0 , 0],[0, -1],[0, -2],[-1, 0]]
                  ],
                  current_rotation: 0,
                  grid_position: Struct.new(:x, :y).new(0, 0),
                  view: :piece_view
end
