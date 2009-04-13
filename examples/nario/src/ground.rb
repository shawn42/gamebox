require 'actor'
require 'graphical_actor_view'

class GroundView < GraphicalActorView
  has_props :layer => 2
end

class Ground < Actor
  has_behaviors :graphical, :physical => {:shape => :poly, 
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
  ]}
end
