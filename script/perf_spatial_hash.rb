require 'bundler'
Bundler.setup

require 'constructor'
require 'publisher'
require 'gamebox'
require 'benchmark'

class Arb 
  include Arbiter
  extend Publisher
  can_fire_anything

  def initialize(spatial)
    @spatial = spatial
    on_collision_of 5, 6 do |f,b|
      puts "collide"
    end
  end
  def stagehand(name)
    @spatial
  end

end

StructShape = Struct.new(:x,:y,:width,:height,:collidable_shape,:radius)
class Shape < StructShape
  extend Publisher
  can_fire_anything
  def center_x;self.x;end
  def center_y;self.y;end
  def actor_type;6;end
end

def do_it(hash, num_times, obj_size)
  arb = Arb.new hash
  rands = [1, 3, 5, 7, 13, 17]
  num_times.times do |i|
    arb.register_collidable Shape.new(i+rands[-(i%6)],
                                      i+rands[-(i%6)],obj_size,obj_size,:circle,obj_size)
  end

  hash.rehash

  arb.find_collisions
end

Benchmark.bm(60) do|b|

  @lots = 5000
  @small_grid = 5
  @medium_grid = 80

  @small_object = 2
  @medium_object = 20
  @large_object = 100

  puts "DEFS: "
  puts "lots: #{@lots}"
  puts "small_grid: #{@small_grid} medium_grid: #{@medium_grid} large_grid: #{@large_grid}"
  puts "small_object: #{@small_object} medium_object: #{@medium_object} large_object: #{@large_object}"


  klass = SpatialHash
  # b.report("w/ lots of small objects in small size grid") do
  #   hash = klass.new @small_grid, true
  #   do_it(hash,@lots, @small_object)
  # end

  # b.report("w/ lots of medium objects in small size grid") do
  #   hash = klass.new @small_grid, true
  #   do_it(hash,@lots, @medium_object)
  # end

  b.report("w/ lots of small objects in medium size grid") do
    hash = klass.new @medium_grid, true
    do_it(hash,@lots, @small_object)
  end
# 
#   b.report("w/ lots of medium objects in medium size grid") do
#     hash = klass.new @medium_grid, true
#     do_it(hash,@lots, @medium_object)
#   end
# 
#   b.report("w/ lots of large objects in small size grid") do
#     hash = klass.new @small_grid, true
#     do_it(hash,@lots, @large_object)
#   end
#   b.report("w/ lots of large objects in small size grid no resize") do
#     hash = klass.new @small_grid, false
#     do_it(hash,@lots, @large_object)
#   end
end

