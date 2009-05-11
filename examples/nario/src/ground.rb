require 'actor'

class GroundView < ActorView
  def draw(target, x_off, y_off)
    bb = @actor.shape.bb
    x = bb.l + x_off
    y = bb.b + y_off
    x2 = bb.r + x_off
    y2 = bb.t + y_off
    target.draw_box_s [x,y], [x2,y2], [25,255,25,255]
    target.draw_box_s [x,y2], [x2,4000], [210,180,140,255]
  end
end

class Ground < Actor
  has_behaviors :graphical, {:physical => {:shape => :poly, 
    :fixed => true,
    :verts => [ 
      [-400,0], 
      [-400,40], 
      [200,40], 
      [400,40], 
      [600,40], 
      [800,40], 
      [2024,40], 
      [2024,0],
  ]}},
  {:layered => {:layer => 0, :parallax => 1}}
end
