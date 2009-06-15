# Tile is a location on the map
class Tile < TwoDGridLocation
  attr_accessor :lit, :seen, :solid, :occupants
  def initialize(x,y)
    super x, y
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

# helper for creating locations more easily
def loc2(x,y)
  TwoDGridLocation.new x, y
end