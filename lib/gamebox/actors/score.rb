class ScoreView < ActorView
  def draw(target,x_off,y_off,z)
    text = @actor.score.to_s
    text = '0'*(6-text.size)+text

    font = @stage.resource_manager.load_font 'Asimov.ttf', 30

    x = @actor.x
    y = @actor.y

    font.draw text, x,y,z#, 1,1,target.convert_color([250,250,250,255])
  end
end
class Score < Actor

  has_behavior :layered => {:layer => 999}

  def setup
    clear if backstage[:score].nil?
  end

  def score
    backstage[:score]
  end

  def clear
    backstage[:score] = 0
  end

  def +(amount)
    backstage[:score] += amount
    self
  end

  def -(amount)
    backstage[:score] -= amount
    self
  end
end
