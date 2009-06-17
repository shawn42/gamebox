require 'inflector'
require 'map'
require 'publisher'

# loads maps from given string array
class MapLoader
  extend Publisher
  can_fire :create_actor
  
  def initialize(config)
    @config = config
  end
  
  def load_map(map, filename)
    full_path = File.join(DATA_PATH,'maps',filename)
    map_lines = File.open(full_path).readlines

    map.size = [map_lines[0].length-1, map_lines.size-1]
    
    map_lines.each_with_index do |row_str, row|
      row_str.strip.length.times do |col|
        tile_klass = @config[:tiles][row_str[col]]
        tile = map.spawn :tile, :x => col, :y => row
        #puts "#{col},#{row} => #{klass} : #{row_str[col]}"
        tile.lit = false
        tile.solid = true if tile_klass == "Wall"
        if tile_klass.nil?
          actor_klass = @config[:actors][row_str[col]]
          unless actor_klass.nil?
            x = col * map.tile_width
            y = row * map.tile_height
            name = Inflector.underscore(actor_klass).to_sym
            fire :create_actor, name, :x=>x, :y=>y
          end
                      
        end
        map.place tile.location, tile
      end
    end
  end
  
end