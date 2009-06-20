require 'level'
require 'map'
require 'map_loader'
require 'tile'
class DemoLevel < Level
  def setup
    @map = create_actor :map
    map_defs = resource_manager.load_config 'map_defs'
    map_loader = MapLoader.new map_defs
        
    #map_loader.load_map @map, 'sample.map'
    
    # smaller maps for now...
    map_loader.build_random_map @map, 200
    
    @rague = map_loader.rague
    
    raise "Invalid map! No Rague (@) was found!" if @rague.nil?

    @rague.when :action_taken do
      give_everyone_their_turn
    end
    
    @rague.when :move_right do
      move_rague [1,0]
    end
    @rague.when :move_left do
      move_rague [-1,0]
    end
    @rague.when :move_up do
      move_rague [0,-1]
    end
    @rague.when :move_down do
      move_rague [0,1]
    end
    viewport.when :scrolled do
      @map.update_drawable_tiles viewport
      @map.update_lit_locations loc2(@rague.tile_x,@rague.tile_y)
    end
    
    viewport.follow @rague
    
  end

  def draw(target, x_off, y_off)
    target.fill [0,0,0,255]
  end
  
  def give_everyone_their_turn
    #puts "NPCs get their turn"
  end
  
  def move_rague(dir)
    new_loc = loc2 @rague.tile_x+dir[0], @rague.tile_y+dir[1]
    new_tile = @map.occupant new_loc
    if new_tile && !new_tile.solid?
      # move the player
      @rague.tile_x = new_loc.x
      @rague.tile_y = new_loc.y
      @rague.y += @map.tile_height * dir[1]
      @rague.x += @map.tile_width * dir[0]

      @rague.handle_tile_contents new_tile
      
      give_everyone_their_turn
    end
  end
end

