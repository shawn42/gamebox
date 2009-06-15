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