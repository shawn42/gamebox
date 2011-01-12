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
    on_collision_of :otherthingy, :thingy do |f,b|
      puts "collide"
    end
  end
  def stagehand(name)
    @spatial
  end

end

class Shape 
  extend Publisher
  can_fire_anything
  attr_accessor :x,:y,:width,:height,:collidable_shape,:radius
  def initialize(*args)
    @x,@y,@width,@height,@collidable_shape,@radius = *args
  end
    
  def center_x;self.x;end
  def center_y;self.y;end
  def actor_type;:thingy;end
end

actor_count = 100
loop_count = 100
obj_size = 40
cell_size = 80

hash = SpatialHash.new cell_size#, true
arb = Arb.new hash
actor_count.times do |i|
  shape = Shape.new(i*20, i*20, obj_size,obj_size,:circle,obj_size)
  arb.register_collidable shape
end

 Benchmark.bm(60) do|b|
 #30.times do |i|
   hash_cell_size = cell_size #+ 5*i
   hash.cell_size = hash_cell_size
   b.report("#{actor_count} actors w/ size #{obj_size} cell size #{hash_cell_size} for #{loop_count} update loops") do
    loop_count.times do
      hash.rehash
      arb.find_collisions
    end
   end
  end 
 #end

puts "hash auto-size:#{hash.cell_size}"
