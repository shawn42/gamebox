require 'actor'

class Background < Actor
  has_behaviors :graphical => {:tiled => true, :num_x_tiles => 4, :num_y_tiles => 2}, 
    :layered => {:layer => 0, :parallax => 10}
end
