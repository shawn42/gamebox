require 'stage'
require 'ftor'
class DemoStage < Stage
  def setup
    super
    @game_field = create_actor :game_field
    @game_field.x = 50
    @game_field.y = 80
  end

  def draw(target)
    target.fill [0,0,0,255]
    super
  end
end

