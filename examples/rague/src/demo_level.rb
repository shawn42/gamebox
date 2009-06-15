require 'level'
require 'map'
require 'tile'
class DemoLevel < Level
  def setup
    @map = create_actor :map, :height => 40, :width => 60
    
    @map.w.times do |col|
      @map.h.times do |row|
        loc = Tile.new col, row
        loc.lit = false
        loc.solid = true if col == 35 && row < 20
        @map.place loc
      end
    end
    
    @rague = create_actor :rague
  
    @rague.when :move_right do
      x,y = @map.screen_to_tile(@rague.x,@rague.y)
      new_loc = loc2 x+1, y
      new_tile = @map.occupant new_loc
      if new_tile && !new_tile.solid?
        # move the player
        @rague.x += @map.tile_width
        @map.update_lit_locations new_loc
      end
    end
    @rague.when :move_left do
      x,y = @map.screen_to_tile(@rague.x,@rague.y)
      new_loc = loc2 x-1, y
      new_tile = @map.occupant new_loc
      if new_tile && !new_tile.solid?
        # move the player
        @rague.x -= @map.tile_width
        @map.update_lit_locations new_loc
      end
    end
    @rague.when :move_up do
      x,y = @map.screen_to_tile(@rague.x,@rague.y)
      new_loc = loc2 x, y-1
      new_tile = @map.occupant new_loc
      if new_tile && !new_tile.solid?
        # move the player
        @rague.y -= @map.tile_height
        @map.update_lit_locations new_loc
      end
    end
    @rague.when :move_down do
      x,y = @map.screen_to_tile(@rague.x,@rague.y)
      new_loc = loc2 x, y+1
      new_tile = @map.occupant new_loc
      if new_tile && !new_tile.solid?
        # move the player
        @rague.y += @map.tile_height
        @map.update_lit_locations new_loc
      end
    end
    viewport.follow @rague
    
    # start the visibility stuff
    x,y = @map.screen_to_tile(@rague.x,@rague.y)
    @map.update_lit_locations loc2(x,y)
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
  end
end

