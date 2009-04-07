require 'actor'
require 'actor_view'

class TetrominoView < ActorView

  def draw(target)
    @actor.image.blit target.screen, [@actor.x,@actor.y]
  end

end

class Tetromino < Actor

  attr_accessor :image

  def setup
    @image = @resource_manager.load_image "green.png"
  end

end
