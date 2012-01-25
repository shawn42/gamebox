require 'benchmark'
$: << File.dirname(__FILE__)+"/../lib/gamebox"
require 'gamebox'


NUM_RUNS = 1000
PROFILE = false
class FakeInput
  def unsubscribe_all(*args);end
end

def run
  config = {
    screen_resolution: [800,600]
  }

  fake_input = FakeInput.new
  af = ActorFactory.new input_manager: fake_input, wrapped_screen: :wrapped_screen
  af.director = FakeUpdate.new
  stage = Stage.new :input_manager, af, :resource_manager, :sound_manager, config, :backstage, {}

  Benchmark.bm(60) do |b|
    b.report("update loop") do

      runs = NUM_RUNS
      if PROFILE
        # runs = 100
        require 'perftools'
        PerfTools::CpuProfiler.start("/tmp/gamebox_perf.txt")
      end
      things = []
      200.times do |i|
        50.times do |j|
          things << stage.spawn(:thinger, x: i*40, y: j*40)
        end
      end


      stage.on_collision_of :thinger, :thinger do |a,b|
        # no op, just want something to call
      end
      runs.times do 
        # move some around
        dist = 10
        [0,2,5,7,13,19].each do |i|
          thing = things[i]
          thing.x = thing.x + dist
          thing.y = thing.y + dist
        end

        stage.update(20)

        [0,2,5,7,13,19].each do |i|
          thing = things[i]
          thing.x = thing.x - dist
          thing.y = thing.y - dist
        end
        stage.update(20)

        to_kill = things.pop
        things << stage.spawn(:thinger, x: to_kill.x, y: to_kill.y)
        to_kill.remove_self
        stage.update(20)
# 
#         puts "\nGARBAGE COLLECTION"
#         # Not even close to exact, but gives a rough idea of what's being collected
#         old_objects = ObjectSpace.count_objects.dup
#         ObjectSpace.garbage_collect
#         new_objects = ObjectSpace.count_objects
# 
#         old_objects.each do |k,v|
#           diff = v - new_objects[k]
#           puts "#{k} #{diff} diff" if diff != 0
#         end
#                 
# 
      end
      PerfTools::CpuProfiler.stop if PROFILE

    end
  end
end
class FakeUpdate
  def update(dt);end
end

class Thinger < Actor
  has_behavior :collidable => {:shape => :circle, :radius => 34}
end

run
