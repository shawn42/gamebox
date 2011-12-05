require 'benchmark'
$: << File.dirname(__FILE__)+"/../lib/gamebox"
require 'gamebox'


NUM_LAYERS = 12
NUM_P_LAYERS = 3
NUM_RUNS = 200_000
PROFILE = true

def run
  config = {
    screen_resolution: [800,600]
  }

  af = Struct.new(:director).new
  stage = Stage.new :input_manager, af, :resource_manager, :sound_manager, config, :backstage, {}
  NUM_P_LAYERS.times do |pl|
    NUM_LAYERS.times do |l|
      stage.register_drawable FakeDrawable.new(l+1, pl+1)
    end
  end

  
  Benchmark.bm(60) do |b|
    b.report("drawing loop") do

      if PROFILE
        require 'perftools'
        PerfTools::CpuProfiler.start("/tmp/gamebox_perf.txt")
      end

      NUM_RUNS.times do 
        stage.draw :target
      end
      PerfTools::CpuProfiler.stop if PROFILE

    end
  end
end

class FakeDrawable
  def initialize(l, pl)
    @layer = l
    @parallax = pl
  end
  def draw(target,xoff,yoff,z);end
  attr_accessor :layer, :parallax
end

run
