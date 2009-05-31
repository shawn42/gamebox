# TwoDGridLocation exibits an x,y,cost location
class TwoDGridLocation
  attr_accessor :x,:y
  def initialize(x,y);@x=x;@y=y;end
  def ==(other)
    @x == other.x and @y == other.y
  end
  
  def <=>(b)
    ret = 1
    if @x == b.x && @y == b.y  
      ret = 0
    end
    ret = -1 if @x <= b.x && @y < b.y
    return ret
  end
  
  def to_s
    "#{@x},#{@y}"
  end
end

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
  
  def place(location, thing)
    @grid[location.x] ||= {}
    @grid[location.x][location.y] = thing
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
