class Game

  constructor :wrapped_screen, :input_manager, :sound_manager,
    :stage_manager

  def setup
    @stage_manager.change_stage_to :demo
  end

  def update(time)
    @stage_manager.update time
    draw
  end

  def draw
    @stage_manager.draw @wrapped_screen
  end

end
