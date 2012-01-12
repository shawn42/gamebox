require 'benchmark'

# Point = Struct.new :x, :y
# class Point
#   attr_accessor :x, :y
#   def initialize(x,y)
#     @x = x
#     @y = y
#   end
# end
NUM = 10_000_000
Benchmark.bm(60) do |b|
  b.report("array") do
    NUM.times do 
      it = [4,6]
      it[0] = 1
      it[1] = 3
      it[0]
      it[1]
    end
  end
  b.report("struct") do
    NUM.times do 
      it = Point.new 4, 6
      it.x = 1
      it.y = 3
      it.x 
      it.y 
    end
  end
end

