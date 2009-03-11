require 'mode'
require 'level'
require 'director'
require 'actor'
require 'actor_view'
require 'actor_factory'

class Ship < Actor
end

class ShipView < ActorView
  def setup
    # TODO subscribe for all events here
  end
  def draw(target)
    target.fill [255,255,255,255]
    target.draw_box_s [100,10], [90,90], [150,150,150,255] 
  end
end


class Game

  constructor :wrapped_screen, :input_manager, :sound_manager, :mode_manager

  def setup()
    @sound_manager.play :current_rider

    # tmp code here, to draw an actor
    # WHERE SHOULD THIS BUILDING LOGIC COME FROM?
    #  - file describing modes? or hard code them?
    #  - levels in each mode? or hard code them?
    #  - directorys in the level? in the "level definition"?
    mode = Mode.new
    @mode_manager.add_mode :demo, mode
    factory = ActorFactory.new @mode_manager
    ship = factory.build :ship
    level = Level.new
    dir = Director.new
    dir.actors << ship
    level.directors << dir
    mode.level = level

    @mode_manager.change_mode_to :demo
  end

  def update(time)
    draw
  end

  def draw
    @mode_manager.draw @wrapped_screen
    @wrapped_screen.flip
  end

end
