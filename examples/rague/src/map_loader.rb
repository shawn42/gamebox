require 'inflector'
require 'map'
require 'dungeon_generator'
require 'publisher'

# loads maps from given string array
class MapLoader
  extend Publisher
  can_fire :monster_spawned
  attr_accessor :rague
  
  def initialize(config)
    @config = config
  end
  
  def build_random_map(map, walk_length=400)
    # TODO randomize starting location
    x = 12
    y = 5
    log "Generating random map ..."
    things_to_place = ['!','!','g','g','g']
    a = Generator.new().create_dungeon(Arena.new(things_to_place), walk_length, true, Walker.new(x,y))
    a[x,y] = '@'
    a[x+1,y] = '<'
    
    puts a
    
    log "done."
    build_map map, a.to_s.split("\n")
  end
  
  def load_map(map, filename)
    full_path = File.join(DATA_PATH,'maps',filename)
    map_lines = File.open(full_path).readlines
    build_map map, map_lines
  end
  
  def build_map(map, map_lines)
    log "Building map..."
    map.size = [map_lines[0].length-1, map_lines.size-1]
    
    map_lines.each_with_index do |row_str, row|
      row_str.strip.length.times do |col|
        x = (col-0.5) * map.tile_width
        y = (row-0.5) * map.tile_height
        
        tile_klass = @config[:tiles][row_str[col].chr]
        tile = map.spawn :tile, :x => x, :y => y, :action => tile_klass,
          :tile_x => col, :tile_y => row, :hide => true
        tile.lit = false
        tile.solid = true if tile_klass == :wall
        
        if tile_klass.nil?
          monster_name = @config[:monsters][row_str[col].chr]
          if monster_name == :rague
            act = map.spawn :rague, :x=>x, :y=>y
            @rague = act 
            @rague.tile_x = col
            @rague.tile_y = row
          else
            if monster_name.nil?
              item_name = @config[:items][row_str[col].chr]
              unless item_name.nil?
                act = map.spawn :item, :name=>item_name, :x=>x, :y=>y, :hide => true
                tile.occupants << act
              end
            else
              act = map.spawn :monster, :name=>monster_name, :x=>x, :y=>y, :hide => true
              tile.occupants << act
              fire :monster_spawned, act
            end
          end
                      
        end
        map.place tile.location, tile
      end
    end
    log "done."
  end
  
end