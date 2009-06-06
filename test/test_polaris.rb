require 'helper'
require 'ai/polaris'
require 'ai/two_d_grid_map'

describe 'A new polaris' do
  before do
    @map = TwoDGridMap.new 10, 20
    @pather = Polaris.new @map
  end

  it 'should return an empty path if destination is not valid' do
    from = TwoDGridLocation.new @map.w-1, @map.h-1
    to = TwoDGridLocation.new @map.w, @map.h
    @pather.guide(from,to).should == nil

    to = TwoDGridLocation.new(-1, -1)
    @pather.guide(from,to).should == nil
  end

  it 'should return an empty path if start is not valid' do
    from = TwoDGridLocation.new @map.w, @map.h
    to = TwoDGridLocation.new @map.w-1, @map.h-1
    @pather.guide(from,to).should == nil
    
    from = TwoDGridLocation.new -1, -1
    @pather.guide(from,to).should == nil
  end
  
  it 'should return the path of "to" for accessible neighbor' do
    from = TwoDGridLocation.new 0, 0
    to = TwoDGridLocation.new 1, 0
    
    path = @pather.guide(from,to)
    path.should != nil
    path.size.should == 1
    
    path.first.cost_to.should == TwoDGridMap::TRAVEL_COST_STRAIGHT
    path.first.dist_from.should == 0
    path.first.location.x.should == to.x
    path.first.location.y.should == to.y
  end
  
  it 'should return the right horizontal path of length 2' do
    from = TwoDGridLocation.new 0, 0
    to = TwoDGridLocation.new 2, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 0
    path.last.location.should == to
  end

  it 'should return the left horizontal path of length 2' do
    from = TwoDGridLocation.new 2, 0
    to = TwoDGridLocation.new 0, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 0
    path.last.location.should == to
  end  
  

  it 'should return the left up diag path of length 2' do
    from = TwoDGridLocation.new 2, 2
    to = TwoDGridLocation.new 0, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 1
    path.last.location.should == to
  end  
  
  it 'should return the right up diag path of length 2' do
    from = TwoDGridLocation.new 2, 2
    to = TwoDGridLocation.new 4, 0
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 3
    path.first.location.y.should == 1
    path.last.location.should == to
  end
  
  it 'should return the right down diag path of length 2' do
    from = TwoDGridLocation.new 2, 2
    to = TwoDGridLocation.new 4, 4
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 3
    path.first.location.y.should == 3
    path.last.location.should == to
  end   
  
  it 'should return the left down diag path of length 2' do
    from = TwoDGridLocation.new 2, 2
    to = TwoDGridLocation.new 0, 4
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 3
    path.last.location.should == to
  end  
  
  it 'should return go around an obstacle' do
    from = TwoDGridLocation.new 0, 0
    to = TwoDGridLocation.new 2, 0
    
    in_the_way = TwoDGridLocation.new 1, 0
    @map.place in_the_way, "ME"
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 2
    
    path.first.location.x.should == 1
    path.first.location.y.should == 1
    path.last.location.should == to
  end
  
  it 'should return shortest path of horizontal and diag length 5' do
    from = TwoDGridLocation.new 0, 0
    to = TwoDGridLocation.new 5, 4
    
    path = @pather.guide(from,to)
    
    path.should != nil
    path.size.should == 5
    
    # make sure that all elements of the path are neighbors
    prev_el = PathElement.new from, nil
    path.each do |path_el|
      @map.neighbors(prev_el.location).should.include? path_el.location
      prev_el = path_el
    end
    
    path.last.location.should == to
  end
  
  it 'should return nil when the shortest path is longer than the max step passed in' do
    from = TwoDGridLocation.new 0, 0
    to = TwoDGridLocation.new 5, 4
    
    path = @pather.guide(from,to,nil,4)
    path.should == nil
  end  

  it 'should return nil when the path does not exist for unit type' do
    from = TwoDGridLocation.new 0, 0
    to = TwoDGridLocation.new 2, 0
    
    path = @pather.guide(from,to,:blocked)
    path.should == nil
  end  

  it 'should return nil when the path does not exist' do
    from = TwoDGridLocation.new 0, 0
    to = TwoDGridLocation.new 2, 0
    
    # put up a wall
    @map.h.times do |i|
      @map.place TwoDGridLocation.new(1, i), "ME"
    end
    
    path = @pather.guide(from,to)
    path.should == nil
    @pather.nodes_considered.should == @map.h
  end
end
