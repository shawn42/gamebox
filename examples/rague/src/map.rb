require 'ai/two_d_grid_map'
require 'ai/line_of_site'

# this is the grid map for rague
class Map < Actor
  attr_accessor :tile_width, :tile_height
  def setup
    @tile_width = 30
    @tile_height = 30
    @map = TwoDGridMap.new @opts[:width], @opts[:height]
    @los = LineOfSite.new @map
  end
  
  def update_lit_locations(source_location, range=11)
    # clear visibility of tiles
    @map.w.times do |col|
      @map.h.times do |row|
        # TODO fix map access.. figure out Location usage (maybe .each_location )
        @map.occupant(loc2(col,row)).lit = false
      end
    end
    
    r = ((range-1)/2).floor
    range.times do |i|
      x = source_location.x
      y = source_location.y
      @los.losline x, y, x-r+i, y-r
      @los.losline x, y, x-r+i, y+r
      @los.losline x, y, x-r, y-r+i
      @los.losline x, y, x+r, y-r+i
      @los.losline x, y, x+1, y-r+i
      @los.losline x, y, x-1, y-r+i
      @los.losline x, y, x-r+i, y-1
      @los.losline x, y, x-r+i, y+1
    end
  end
  
  def screen_to_tile(x,y)
    tiles = [(x / @tile_width).floor, (y / @tile_height).floor]
    tiles[0] = 0 if tiles[0] < 0
    tiles[0] = @map.w - 1 if tiles[0] > @map.w - 1
    tiles[1] = 0 if tiles[1] < 0
    tiles[1] = @map.h - 1 if tiles[1] > @map.h - 1
    tiles
  end
  
  def method_missing(name, *args)
    @map.send name, *args
  end
end

class MapView < ActorView
  def draw(target, x_off, y_off)
    @actor.w.times do |col|
      @actor.h.times do |row|
        x = @actor.x+col*@actor.tile_width+x_off
        y = @actor.y+row*@actor.tile_height+y_off
        
        tile = @actor.occupant loc2(col,row)
        
        alpha = 80        
        alpha = 155 if tile.seen?
        alpha = 255 if tile.lit?
        
        # TODO move color to tile?
        color = [150,250,45,alpha]
        color = [150,50,45,alpha] if tile.solid?
        
        target.draw_box_s [x,y], [x+@actor.tile_width,y+@actor.tile_height], color
      end
    end
    
    @actor.w.times do |col|
      @actor.h.times do |row|
        x = @actor.x+col*@actor.tile_width+x_off
        y = @actor.y+row*@actor.tile_height+y_off
        target.draw_box [x,y], [x+@actor.tile_width,y+@actor.tile_height], [155,155,155,255]
      end
    end
  end
end
