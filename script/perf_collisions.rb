require 'benchmark'
$: << File.dirname(__FILE__)+"/../lib/gamebox"
require 'gamebox'


NUM_RUNS = 800
PROFILE = true

def run
  config = {
    screen_resolution: [800,600]
  }

  af = ActorFactory.new input_manager: :input_manager, wrapped_screen: :wrapped_screen
  af.director = FakeUpdate.new
  stage = Stage.new :input_manager, af, :resource_manager, :sound_manager, config, :backstage, {}

  things = []
  20.times do |i|
    5.times do |j|
      things << stage.spawn(:thinger, x: i*40, y: j*40)
    end
  end

  Benchmark.bm(60) do |b|
    b.report("update loop") do

      runs = NUM_RUNS
      if PROFILE
        # runs = 100
        require 'perftools'
        PerfTools::CpuProfiler.start("/tmp/gamebox_perf.txt")
      end

      runs.times do 
        things[0].x = things[0].x + 1
        things[2].x = things[0].x + 1
        things[0].x = things[2].x - 1
        things[2].x = things[2].x - 1
        things[0].y = things[0].y + 1
        things[2].y = things[0].y + 1
        things[0].y = things[2].y - 1
        things[2].y = things[2].y - 1
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
