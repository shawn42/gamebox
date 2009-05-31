$: << File.dirname(__FILE__)+"/../lib/gamebox"

require 'ai/polaris'
require 'ai/two_d_grid_map'

@map = TwoDGridMap.new 100, 90

from = TwoDGridLocation.new 0, 0
to = TwoDGridLocation.new 9, 0
@pather = Polaris.new @map

require 'benchmark'
Benchmark.bm do|b|
  
  b.report("warm up") do
    10.times { path = @pather.guide(from,to) }
  end

  b.report("shorter path") do
    10.times { path = @pather.guide(from,to) }
  end

  to = TwoDGridLocation.new 92, 0
  b.report("longer path") do
    10.times { path = @pather.guide(from,to) }
  end

  # put up a wall
  @map.h.times do |i|
    @map.place TwoDGridLocation.new(89, i), "ME"
  end

  b.report("blocked path") do
    10.times { path = @pather.guide(from,to) }
  end
end
