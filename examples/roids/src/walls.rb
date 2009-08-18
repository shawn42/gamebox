require 'actor'

class LeftWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :elasticity => 0.4,
    :verts => [[0,0],[0,800],[1,800],[1,0]]}
end

class TopWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :elasticity => 0.4,
    :verts => [[0,0],[0,1],[1024,1],[1024,0]]}
end

class BottomWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :elasticity => 0.4,
    :x => 0,
    :y => 799,
    :verts => [[0,0],[0,1],[1024,1],[1024,0]]}
end

class RightWall < Actor
  has_behaviors :physical => {:shape => :poly, 
    :fixed => true,
    :elasticity => 0.4,
    :x => 1023,
    :y => 0,
    :verts => [[0,0],[0,800],[1,800],[1,0]]}
end
