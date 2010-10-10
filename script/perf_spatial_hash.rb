$: << File.dirname(__FILE__)+"/../lib/gamebox"

require 'spatial_hash'
require 'new_spatial_hash'
require 'benchmark'

Shape = Struct.new(:x,:y,:width,:height)

def do_it(hash, num_times, obj_size)
  num_times.times do |i|
    hash.add(Shape.new(i,i,obj_size,obj_size))
  end

  num_times.times do |i|
    hash.items_at i, i
  end

  hash.rehash
  hash.rehash
  hash.rehash
  hash.rehash

  num_times.times do |i|
    hash.items_at i, i
  end
end

OldSpatialHash = SpatialHash

Benchmark.bm(60) do|b|
  
  @lots = 1_000
  @small_grid = 5
  @medium_grid = 80

  @small_object = 2
  @medium_object = 20
  @large_object = 100

  impls = %w{old new}
  impls.each do |impl|
    klass = ObjectSpace.const_get "#{impl.capitalize}SpatialHash"
    b.report("#{impl} w/ lots of small objects in small size grid") do
      hash = klass.new @small_grid, true
      do_it(hash,@lots, @small_object)
    end

    b.report("#{impl} w/ lots of medium objects in small size grid") do
      hash = klass.new @small_grid, true
      do_it(hash,@lots, @medium_object)
    end

    b.report("#{impl} w/ lots of small objects in medium size grid") do
      hash = klass.new @medium_grid, true
      do_it(hash,@lots, @small_object)
    end

    b.report("#{impl} w/ lots of medium objects in medium size grid") do
      hash = klass.new @medium_grid, true
      do_it(hash,@lots, @medium_object)
    end

    b.report("#{impl} w/ lots of large objects in small size grid") do
      hash = klass.new @small_grid, true
      do_it(hash,@lots, @large_object)
    end
    b.report("#{impl} w/ lots of large objects in small size grid no resize") do
      hash = klass.new @small_grid, false
      do_it(hash,@lots, @large_object)
    end
  end

end
