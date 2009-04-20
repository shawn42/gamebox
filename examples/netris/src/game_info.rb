require 'actor'
require 'actor_view'

class GameInfoView < ActorView

  def draw(target, x_off, y_off)
    level = @actor.font.render("Level #{@actor.current_level}", true, [250, 250, 250, 255])
    score = @actor.font.render("%06d" % [@actor.score], true, [250, 250, 250, 255])

    level.blit target.screen, [@actor.x, @actor.y]
    score.blit target.screen, [@actor.x, @actor.y + 40]
  end

end

class GameInfo < Actor
  attr_accessor :current_level, :score

  attr_reader :font

  def setup
    @font = @resource_manager.load_font("Asimov.ttf", 30)
  end
end
