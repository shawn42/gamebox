class ScoreView < ActorView
  def draw(target,x_off,y_off)
    text = @actor.score.to_s
    text = '0'*(6-text.size)+text

    font = @mode.resource_manager.load_font 'Asimov.ttf', 30
    text_image = font.render text, true, [250,250,250,255]

    x = @actor.x
    y = @actor.y

    text_image.blit target.screen, [x,y]
  end
end
class Score < Actor
  has_behavior :layered => {:layer => 999}
  attr_accessor :score

  def setup
    clear
  end

  def clear
    @score = 0
  end

  def +(amount)
    @score += amount
    self
  end

  def -(amount)
    @score -= amount
    self
  end
end
