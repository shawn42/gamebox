require 'level'
require 'ftor'
class DemoLevel < Level
  def setup
    create_actor :background, :x => -100, :y => -100
    @map = create_actor :mappy, :map_filename => 'map.txt'
    @major_ruby = @map.major_ruby

    create_actor :logo, :x => 900, :y => 650
    @score = create_actor :score, :x => 90, :y => 50

    sound_manager.play_music :future

    viewport.follow @major_ruby
    viewport.x_offset_range = 540..2190
    viewport.y_offset_range = 0..830
  end

  def update(time_delta)
    super time_delta

    uncollected_gems = @map.pretty_gems.size
    @major_ruby.collect_gems @map.pretty_gems

    remaining_gems = @map.pretty_gems.size
    collected_count = uncollected_gems-remaining_gems
    @score.score += collected_count*10

    fire :next_level if remaining_gems == 0
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
  end
end

