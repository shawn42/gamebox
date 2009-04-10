require 'actor'
require 'actor_view'

class GroundView < ActorView
  def draw(target)
    bb = @actor.shape.bb
    target.draw_box_s [bb.l,bb.t], [bb.r,bb.b], [40,245,45,255]
  end
end

class Ground < Actor
  has_behaviors :physical => {:shape => :poly, 
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
