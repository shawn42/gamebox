define_actor :square do
  has_behaviors do
    positioned
    colored color: 'orange.png'
  end

  has_attributes  blocks: [[
                    [0, 0],[1, 0],
                    [1, -1],[0, -1]
                  ]],
                  current_rotation: 0,
                  grid_position: Struct.new(:x, :y).new(0, 0),
                  view: :piece_view

end
