require 'actor'

class Background < Actor
  has_behaviors :graphical, :layered => {:layer => 0, :parallax => 10}

  def setup

    map = @opts[:map]
    x_tiles = (map.tw*map.width/image.size[0]).ceil
    y_tiles = (map.th*map.height/image.size[1]).ceil

    is_no_longer :graphical
    dynamic_behavior = {:graphical => {:tiled => true, :num_x_tiles => x_tiles, :num_y_tiles => y_tiles}}
    is dynamic_behavior

  end
end
