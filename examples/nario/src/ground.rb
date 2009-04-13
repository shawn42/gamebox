require 'actor'
require 'actor_view'

class GroundView < ActorView
  def draw(target,x_off,y_off)
    bb = @actor.shape.bb
    target.draw_box_s [bb.l+x_off,bb.t+y_off], [bb.r+x_off,bb.b+y_off], [40,245,45,255]
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
