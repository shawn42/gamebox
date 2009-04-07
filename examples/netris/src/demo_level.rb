require 'level'
require 'ftor'
class DemoLevel < Level
  def setup
    @game_field = @actor_factory.build :game_field, self
    @game_field.x = 50
    @game_field.y = 80

    @game_field.when :next_tetromino do
      tet = @actor_factory.build :tetromino, self
      tet.x = @game_field.x + rand(240)
      tet.y = @game_field.y + rand(480)
    end
  end

  def draw(target)
  end
end

