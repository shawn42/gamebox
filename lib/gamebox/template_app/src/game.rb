require 'mode'
require 'level'
require 'director'
require 'actor'
class Sly < Actor
  def draw(target)
    target.fill [255,255,255,255]
    target.draw_box_s [100,10], [90,90], [150,150,150,255] 
  end
end
class Game

  constructor :wrapped_screen, :input_manager, :sound_manager

  def setup()
    @sound_manager.play :current_rider

    # tmp code here, to draw an actor
    act = Sly.new
    @mode = Mode.new
    level = Level.new
    dir = Director.new
    dir.actors << act
    level.directors << dir
    @mode.level = level
  end

  def update(time)
    draw
  end

  def draw
    @mode.draw @wrapped_screen
    @wrapped_screen.flip
  end

end
