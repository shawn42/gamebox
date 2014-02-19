require 'polaris'
require 'two_d_grid_map'
require 'line_of_site'
require 'algorithms'
include Containers

# this is the grid map for rague
define_actor :map do
  has_behaviors :positioned, :maplike
end

define_behavior :mapped do
  requires_behaviors :positioned
  setup do
    actor.has_attributes :location
  end
end

define_behavior :maplike do

  requires :stage, :viewport
  setup do
    actor.has_attributes :map, :los, :size

    actor.has_attributes tile_width: 30,
                         tile_height: 30,
                         drawable_tiles: Stack.new

    actor.when :size_changed do
      update_size
    end
    reacts_with :place, :update_drawable_tiles, :update_lit_locations, :move_to
  end

  helpers do

    def update_size
      s = actor.size
      actor.map = TwoDGridMap.new s[0], s[1]
      actor.los = LineOfSite.new actor.map
    end
    
    def update_drawable_tiles(viewport)
      
      actor.drawable_tiles.each do |t|
        t.react_to :hide
      end
      actor.drawable_tiles = Stack.new
      left = actor.x - viewport.x_offset
      right = left + viewport.width
      top = actor.y - viewport.y_offset
      bottom = top + viewport.height
      
      l,t = screen_to_tile left, top
      r,b = screen_to_tile right, bottom
      
      (l..r+1).each do |col|
        (t..b+1).each do |row|
          tile = actor.map.occupant(loc2(col,row))
          if tile
            tile.react_to :show
            actor.drawable_tiles.push tile
          end
        end
      end
      
    end
    
    def update_lit_locations(source_location, range=11)
      # clear visibility of tiles
      actor.drawable_tiles.each do |t|
        t.lit = false
      end
      
      r = ((range-1)/2).floor
      range.times do |i|
        x = source_location.x
        y = source_location.y
        actor.los.losline x, y, x-r+i, y-r
        actor.los.losline x, y, x-r+i, y+r
        actor.los.losline x, y, x-r, y-r+i
        actor.los.losline x, y, x+r, y-r+i
        actor.los.losline x, y, x+1, y-r+i
        actor.los.losline x, y, x-1, y-r+i
        actor.los.losline x, y, x-r+i, y-1
        actor.los.losline x, y, x-r+i, y+1
      end
    end
    
    def screen_to_tile(x,y)
      tiles = [(x / actor.tile_width).floor, (y / actor.tile_height).floor]
      tiles[0] = 0 if tiles[0] < 0
      tiles[0] = actor.map.w - 1 if tiles[0] > actor.map.w - 1
      tiles[1] = 0 if tiles[1] < 0
      tiles[1] = actor.map.h - 1 if tiles[1] > actor.map.h - 1
      tiles
    end
    
    def place(location, thing=nil)
      actor.map.place location, thing
    end
    
    def occupant(location)
      actor.map.occupant location
    end  
    
    def move_to(thing, location)
      new_tile = occupant location
      if thing.location
        old_tile = occupant thing.location 
        old_tile.occupants.delete thing
      end
      new_tile.occupants << thing
      thing.location = location
      
      # TODO is there a better way to keep x,y in sync with map locaiton?
      thing.x = (location.x-0.5)*actor.tile_width
      thing.y = (location.y-0.5)*actor.tile_height
    end
    
  end
end
