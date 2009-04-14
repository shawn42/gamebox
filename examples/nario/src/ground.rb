require 'actor'

class Ground < Actor
  has_behaviors :graphical, {:physical => {:shape => :poly, 
    :fixed => true,
    :verts => [ 
      [0,0], 
      [0,80], 
      [200,80], 
      [400,80], 
      [600,80], 
      [800,80], 
      [1024,80], 
      [1024,0],
  ]}},
  {:layered => {:layer => 0, :parallax => 2}}
end
