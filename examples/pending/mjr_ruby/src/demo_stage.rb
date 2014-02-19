
class DemoStage < Stage
  def setup
    super
    @map = spawn :mappy, :map_filename => 'map.txt'

    spawn :background, :x => -100, :y => -100, :map => @map
    @major_ruby = @map.major_ruby

    create_actor :logo, :x => 900, :y => 650
    @score = spawn :score, :x => 90, :y => 50
    
    sound_manager.play_music :future
    
    viewport.follow @major_ruby
    
    min_x = (viewport.width/2.0-@map.tw).floor
    max_x = (@map.tw*@map.width-viewport.width/2.0).floor
    min_y = (viewport.height/2.0-@map.th).floor
    max_y = (@map.th*@map.height-viewport.height/2.0).floor
    # invalid range if max is < min or less than 0? array magic sort here
    x_range = [min_x,max_x].sort
    y_range = [min_y,max_y].sort
    viewport.x_offset_range = x_range.min..x_range.max
    viewport.y_offset_range = y_range.min..y_range.max
  end

  def update(time_delta)
    super 

    # TODO use built in collision detection
    collected = @major_ruby.collect_gems @map.pretty_gems
    @map.remove collected
    @score += collected.size*10
    fire :next_level if @map.finished?
  end

end
