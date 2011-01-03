
require 'ftor'
class DemoStage < Stage
  def setup
    super
    @map = create_actor :mappy, :map_filenames => 'map.txt,map2.txt'
    @map.when :move_layer do |*args|
      fire :move_layer, *args
    end

    create_actor :background, :x => -100, :y => -100, :map => @map
    @major_ruby = @map.major_ruby

    create_actor :logo, :x => 900, :y => 650
    @score = create_actor :score, :x => 90, :y => 50

    sound_manager.play_music :future

    viewport.follow @major_ruby

    min_x = (viewport.width/2.0-@map.tw).floor
    max_x = (@map.tw*@map.width-viewport.width/2.0).floor
    min_y = (viewport.height/2.0-@map.th).floor
    max_y = (@map.th*@map.height-viewport.height/2.0).floor
    viewport.x_offset_range = min_x..max_x
    viewport.y_offset_range = min_y..max_y
  end

  def update(time_delta)
    super 

    collected = @major_ruby.collect_gems @map.pretty_gems
    @map.remove collected
    @score += collected.size*10


    fire :next_level if @map.finished?
  end

end

