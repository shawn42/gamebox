class Game

  constructor :wrapped_screen, :input_manager, :sound_manager,
    :mode_manager

  def setup
#    @sound_manager.play :current_rider

    @mode_manager.change_mode_to :default
  end

  def update(time)
    @mode_manager.update time
    draw
  end

  def draw
    @mode_manager.draw @wrapped_screen
    @wrapped_screen.flip
  end

end
