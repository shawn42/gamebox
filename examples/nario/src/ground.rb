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
    :mass => 99_999,
    :verts => [ [0,0], [0,80], 
      [1024,80], [1024,0],
  ]}
end
