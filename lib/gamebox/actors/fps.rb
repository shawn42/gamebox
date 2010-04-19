class FpsView < ActorView
  def draw(target,x_off,y_off)
    text = @actor.fps.to_s
    text = '0'*(6-text.size)+text if text.size < 6

    font = @stage.resource_manager.load_font 'Asimov.ttf', 30
    text_image = font.render text, true, [250,250,250,255]

    x = @actor.x
    y = @actor.y

    text_image.blit target.screen, [x,y]
  end
end
class Fps < Actor

  has_behavior :layered => {:layer => 999}

  def fps
    input_manager.current_framerate.round
  end

end
