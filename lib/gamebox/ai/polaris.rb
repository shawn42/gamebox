require 'sorted_list'

# Polaris is the star that guides, aka "The North Star".  It implements the A* algorithm.
class Polaris
  
  def initialize(map)
    @map = map
  end
  
  def guide(from, to, unit_type=nil, max_depth=400)
    return nil if @map.blocked? from, unit_type or @map.blocked? to, unit_type
    from_element = PathElement.new(from)
    from_element.dist_from = @map.distance(from,to)
    open = SortedList.new [from_element]
    closed = SortedList.new
    step = 0
    
    until open.empty? or step > max_depth
      step += 1
      
      current_element = open.shift
      
      loc = current_element.location
      if @map.cost(loc,to) == 0
        path = []
        until current_element.parent.nil?
          path.unshift current_element
          current_element = current_element.parent
        end

        return path
      else
        closed.add current_element
        for next_door in @map.neighbors(loc)
          el = PathElement.new(next_door,current_element)
          it = closed.find(el)
          next unless it.nil?
          
          unless @map.blocked? next_door, unit_type
            next_door_element = open.find el
            g = current_element.cost_to + @map.cost(loc, next_door)
            if next_door_element.nil?
              # add to open
              el.cost_to = g
              el.dist_from = @map.distance(next_door,to)
              
              open << el
            elsif next_door_element.cost_to > g
              # update the parent and cost
              next_door_element.parent = current_element
              next_door_element.cost_to = g
            end
          end
        end
      end
    end
    nil
  end
end

class PathElement
  include Comparable
  
  attr_accessor :location, :parent
  attr_reader :cost_to, :dist_from, :rating
  def initialize(location=nil,parent=nil)
    @location = location
    @parent = parent
    @cost_to = 0
    @dist_from = 0
    @rating = 99_999
  end
  
  def cost_to=(new_cost)
    @cost_to = new_cost
    reset_rating
  end
  
  def dist_from=(new_dist_from)
    @dist_from = new_dist_from
    reset_rating
  end
  
  def reset_rating
    @rating = @cost_to + @dist_from
  end
  
  def to_s
    "#{@location} at cost of #{@cost_to} and rating of #{@rating}"
  end
  
  def <=>(b)
    a = self
    if a.rating < b.rating
      return -1
    elsif a.rating > b.rating
      return 1
    else
      0
    end
  end
  def ==(other)
    return false if other.nil?
    @location == other.location
  end
end