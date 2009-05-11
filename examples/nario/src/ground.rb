require 'actor'

class GroundView < ActorView
  def draw(target, x_off, y_off)
    bb = @actor.shape.bb
    x = bb.l + x_off
    y = bb.b + y_off
    x2 = bb.r + x_off
    y2 = bb.t + y_off
    target.draw_box_s [x,y], [x2,y2], [255,25,25,255]
  end
end

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
  {:layered => {:layer => 0, :parallax => 1}}
end
