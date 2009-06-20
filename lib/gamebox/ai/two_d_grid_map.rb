require 'ai/two_d_grid_location'

# TwoDGridMap exibits the contract that the map requires. 
# Works on an X,Y grid that uses Ftors for 2D vectors
class TwoDGridMap
  attr_accessor :w, :h
  TRAVEL_COST_DIAG = 14
  TRAVEL_COST_STRAIGHT = 10
  
  def initialize(w,h)
    @w = w
    @h = h
    @grid = {}
  end
  
  def size
    [@w,@h]
  end
  
  # place thing at location. If thing is nil, location will be placed in the map
  def place(location, thing=nil)
    thing ||= location
    @grid[location.x] ||= {}
    @grid[location.x][location.y] = thing
  end
  
  def occupant(location)
    @grid[location.x][location.y] if @grid[location.x]
  end
  
  def clear(location)
    @grid[location.x] ||= {}
    @grid[location.x][location.y] = nil
  end
  
  # is the location available for the specified type
  def blocked?(location, type=nil)
    return true if type == :blocked
    return true if location.x >= @w || location.y >= @h || location.x < 0 || location.y < 0
    if @grid[location.x] and @grid[location.x][location.y]
      return true
    else
      return false
    end
  end
  
  # returns a list of neighbors and their distance
  def neighbors(location)
    x = location.x
    y = location.y
    [
      TwoDGridLocation.new(x-1, y-1),
      TwoDGridLocation.new(x-1, y+1),
      TwoDGridLocation.new(x+1, y-1),
      TwoDGridLocation.new(x+1, y+1),
      TwoDGridLocation.new(x-1, y),
      TwoDGridLocation.new(x+1, y),
      TwoDGridLocation.new(x, y-1),
      TwoDGridLocation.new(x, y+1)
    ]
  end
  
  def distance(from,to)
    h_diagonal = [(from.x-to.x).abs, (from.y-to.y).abs].min
    h_straight = ((from.x-to.x).abs + (from.y-to.y).abs)
    return TRAVEL_COST_DIAG * h_diagonal + TRAVEL_COST_STRAIGHT * (h_straight - 2*h_diagonal)
  end
  
  # return the cost to go from => to (assuming from and to are neighbors)
  def cost(from, to)
    if from.x == to.x or from.y == to.y
      if from.x == to.x and from.y == to.y
        0
      else
        TRAVEL_COST_STRAIGHT
      end
    else
      TRAVEL_COST_DIAG
    end
  end
end
