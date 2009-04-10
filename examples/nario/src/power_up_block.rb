require 'actor'

class PowerUpBlock < Actor
  has_behaviors :graphical, :physical => {
    :shape => :poly,
    :fixed => true,
    :verts => [[-30,-30],[-30,30],[30,30],[30,-30]]}
end
