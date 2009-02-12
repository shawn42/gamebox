class Game

  constructor :wrapped_screen, :input_manager

  def setup()
  end

  def update(time)
    draw
  end

  def draw
    @wrapped_screen.fill [255,255,255,255]
    @wrapped_screen.draw_box_s [10,10], [90,90], [150,150,150,255] 
    @wrapped_screen.flip
  end

end
