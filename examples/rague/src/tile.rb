# Tile is a location on the map
class Tile < Actor
  has_behaviors :animated
  attr_accessor :seen, :solid, :occupants, :location
  
  def setup
    tile_x = @opts[:tile_x]
    tile_y = @opts[:tile_y]
    new_action = @opts[:action]
    new_action ||= :floor
    self.action = new_action
    stop_animating
    
    tile_x ||= 0
    tile_y ||= 0
    @location = loc2 tile_x, tile_y
    @occupants = []
  end
  
  def lit=(isLit)
    @lit = isLit
    if isLit
      @occupants.each do |occ|
        occ.show unless occ.visible?
      end
    else
      @occupants.each do |occ|
        occ.hide if occ.visible?
      end
    end
  end
  
  # returns true if the tile is currenlty being lit by the player
  def lit?
    @lit
  end
  
  # returns true if the player has ever seen this tile
  def seen?
    @seen
  end
  
  # returns true if this tile is solid (ie wall)
  def solid?
    @solid
  end
  
end

class TileView < GraphicalActorView
  
  def draw(target, x_off, y_off)
    w = 30
    h = 30
    x = @actor.x+x_off
    y = @actor.y+y_off
    
    if @actor.seen? || @actor.lit?  
      super target, x_off, y_off     
      #@actor.image.blit target.screen, [x,y]
    end

    alpha = 255
    alpha -= 155 if @actor.seen?
    alpha = 0 if @actor.lit?
  
    color = [0,0,0,alpha]
    target.draw_box_s [x,y], [x+w-1,y+h-1], color
  end

end

# helper for creating locations more easily
def loc2(x,y)
  TwoDGridLocation.new x, y
end