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
      give_every_their_turn
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
    end
    
    viewport.follow @rague
    
    # start the visibility stuff
    x,y = @map.screen_to_tile(@rague.x,@rague.y)
    @map.update_lit_locations loc2(x,y)
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
  end
  
  def give_every_their_turn
    puts "NPCs get their turn"
  end
  
  def move_rague(dir)
    log "Starting Rague's turn ..."
    x,y = @map.screen_to_tile(@rague.x,@rague.y)
    new_loc = loc2 x+dir[0], y+dir[1]
    new_tile = @map.occupant new_loc
    if new_tile && !new_tile.solid?
      # move the player
      @rague.y += @map.tile_height * dir[1]
      @rague.x += @map.tile_width * dir[0]
      log "Starting tile contents ..."
      @rague.handle_tile_contents new_tile
      log "done."
      
      log "Updating lit locations ..."
      @map.update_lit_locations new_loc
      log "done."
      
      give_every_their_turn
    end
    
    log "done."
  end
end

