define_actor :bar do
  has_behaviors do
    positioned
    colored color: 'light_blue.png'
  end
  has_attributes  blocks: [[
                      [-1, 0],
                      [0, 0],
                      [1, 0],
                      [2, 0]
                    ],[
                      [0, -2],
                      [0, -1],
                      [0, 0],
                      [0, 1]
                    ]],
                  current_rotation: 0,
                  grid_position: Struct.new(:x, :y).new(0, 0),
                  view: :piece_view
end
