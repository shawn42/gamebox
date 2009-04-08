require 'level'
require 'ftor'
class DemoLevel < Level
  def setup
    @game_field = create_actor :game_field
    @game_field.x = 50
    @game_field.y = 80
  end

  def draw(target)
  end
end

