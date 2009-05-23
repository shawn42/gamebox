require 'helper'
require 'ai/polaris'

# FakeLocation exibits an x,y,cost location
class FakeLocation
  attr_accessor :x,:y
  def initialize(x,y);@x=x;@y=y;end
  def ==(other)
    @x == other.x and @y == other.y
  end
  def to_s
    "#{@x},#{@y}"
  end
end

# FakeMap exibits the contract that the map requires. 
# Works on an X,Y grid that uses Ftors for 2D vectors
class FakeMap
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
      FakeLocation.new(x-1, y-1),
      FakeLocation.new(x-1, y+1),
      FakeLocation.new(x+1, y-1),
      FakeLocation.new(x+1, y+1),
      FakeLocation.new(x-1, y),
      FakeLocation.new(x+1, y),
      FakeLocation.new(x, y-1),
      FakeLocation.new(x, y+1)
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

describe 'A new polaris' do
  before do
    @map = FakeMap.new 10, 20
    @pather = Polaris.new @map
  end

  it 'should return an empty path if destination is not valid' do
    from = FakeLocation.new @map.w-1, @map.h-1
    to = FakeLocation.new @map.w, @map.h
    @pather.guide(from,to).should == nil

    to = FakeLocation.new(-1, -1)
    @pather.guide(from,to).should == nil
  end

  it 'should return an empty path if start is not valid' do
    from = FakeLocation.new @map.w, @map.h
    to = FakeLocation.new @map.w-1, @map.h-1
    @pather.guide(from,to).should == nil
    
    from = FakeLocation.new -1, -1
    @pather.guide(from,to).should == nil
  end
  
  it 'should return the path of "to" for accessible neighbor' do
    from = FakeLocation.new 0, 0
    to = FakeLocation.new 1, 0
    
    path = @pather.guide(from,to)
    path.should != nil
    path.size.should == 1
    
    path.first.cost_to.should == FakeMap::TRAVEL_COST_STRAIGHT
    path.first.dist_from.should == 0
    path.first.location.x.should == to.x
    path.first.location.y.should == to.y
  end
  
  it 'should return the right horizontal path of length 2' do
    from = FakeLocation.new 0, 0
    to = FakeLocation.new 2, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 0
    path.last.location.should == to
  end

  it 'should return the left horizontal path of length 2' do
    from = FakeLocation.new 2, 0
    to = FakeLocation.new 0, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 0
    path.last.location.should == to
  end  
  

  it 'should return the left up diag path of length 2' do
    from = FakeLocation.new 2, 2
    to = FakeLocation.new 0, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 1
    path.last.location.should == to
  end  
  
  it 'should return the right up diag path of length 2' do
    from = FakeLocation.new 2, 2
    to = FakeLocation.new 4, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 3
    path.first.location.y.should == 1
    path.last.location.should == to
  end
  
  it 'should return the right down diag path of length 2' do
    from = FakeLocation.new 2, 2
    to = FakeLocation.new 4, 4
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 3
    path.first.location.y.should == 3
    path.last.location.should == to
  end   
  
  it 'should return the left down diag path of length 2' do
    from = FakeLocation.new 2, 2
    to = FakeLocation.new 0, 4
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 3
    path.last.location.should == to
  end  
  
  it 'should return go around an obstacle' do
    from = FakeLocation.new 0, 0
    to = FakeLocation.new 2, 0
    
    in_the_way = FakeLocation.new 1, 0
    @map.place in_the_way, "ME"
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 1
    path.last.location.should == to
  end
  
  it 'should return shortest path of horizontal and diag length 5' do
    from = FakeLocation.new 0, 0
    to = FakeLocation.new 5, 4
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 5
    
    # TODO how to check the shortest path?
    # check each node to make sure they are neighbors?
    path.first.location.x.should == 1
    path.first.location.y.should == 1
    path.last.location.should == to
  end
  
  it 'should return nil when the shortest path is longer than the max step passed in' do
    from = FakeLocation.new 0, 0
    to = FakeLocation.new 5, 4
    
    path = @pather.guide(from,to,nil,4)
    path.should == nil
  end  
  
  it 'should return nil when the path does not exist' do
    from = FakeLocation.new 0, 0
    to = FakeLocation.new 2, 0
    
    # put up a wall
    @map.h.times do |i|
      @map.place FakeLocation.new(1, i), "ME"
    end
    
    path = @pather.guide(from,to)
    path.should == nil
  end  

  it 'should return nil when the path does not exist for unit type' do
    from = FakeLocation.new 0, 0
    to = FakeLocation.new 2, 0
    
    path = @pather.guide(from,to,:blocked)
    path.should == nil
  end  
end
