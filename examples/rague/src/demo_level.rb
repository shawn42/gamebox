require 'level'
require 'map'
require 'map_loader'
require 'tile'
class DemoLevel < Level
  def setup
    @map = create_actor :map
    map_defs = resource_manager.load_config 'map_defs'
    map_loader = MapLoader.new map_defs
    
    map_loader.when :create_actor do |name, opts|
      act = create_actor name, opts
      @rague = act if name == :rague
    end
    
    map_loader.load_map @map, 'entry.map'
    
    @rague.when :action_taken do
      puts "NPCs get their turn"
    end
    
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
    viewport.when :scrolled do
      @map.update_drawable_tiles viewport
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

