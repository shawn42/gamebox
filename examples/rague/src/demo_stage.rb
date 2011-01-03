
require 'map'
require 'map_loader'
require 'tile'
class DemoStage < Stage
  def setup
    super
    @map = create_actor :map
    map_defs = resource_manager.load_config 'map_defs'
    map_loader = MapLoader.new map_defs
    #map_loader.load_map @map, 'sample.map'
    
    @monsters = []
    map_loader.when :monster_spawned do |monster|
      monster.when :move_right do
        move_monster monster, [1,0]
      end
      monster.when :move_left do
        move_monster monster, [-1,0]
      end
      monster.when :move_up do
        move_monster monster, [0,-1]
      end
      monster.when :move_down do
        move_monster monster, [0,1]
      end
      @monsters << monster
    end
    
    
    # smaller maps for now...
    map_loader.build_random_map @map, 400
    
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
      @map.update_lit_locations loc2(@rague.location.x,@rague.location.y)
    end
       
    viewport.follow @rague
    
  end

  def draw(target)
    target.fill [0,0,0,255]
    super
  end
  
  def give_everyone_their_turn
    @monsters.each do |m|
      m.update 0
    end
  end
  
  def move_monster(monster, dir)
    new_loc = loc2 monster.location.x+dir[0], monster.location.y+dir[1]
    new_tile = @map.occupant new_loc
    if new_tile && !new_tile.solid?
      @map.move_to monster, new_loc
    end
  end
  
  def move_rague(dir)
    new_loc = loc2 @rague.location.x+dir[0], @rague.location.y+dir[1]
    new_tile = @map.occupant new_loc
    if new_tile && !new_tile.solid?
      @map.move_to @rague, new_loc
      @rague.handle_tile_contents new_tile
      
      give_everyone_their_turn
    end
  end
end

