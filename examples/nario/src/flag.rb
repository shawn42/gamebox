

class Flag < Actor
  has_behaviors :graphical, :updatable, 
    :physical => {
        :shape => :poly,
        :fixed => true,
        :verts => [[-5,-103],[-5,103],[5,103],[5,-103]]},
    :layered => {:layer => 2, :parallax => 1}

end
