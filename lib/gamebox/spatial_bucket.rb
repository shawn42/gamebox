class SpatialBucket < Array
  attr_accessor :x, :y
  def initialize(x,y)
    @x = x
    @y = y
    super()
  end
end

