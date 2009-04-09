require 'actor'
require 'actor_view'

class TetrominoView < ActorView

  BLOCK_SIZE = 24

  def draw(target)
    @actor.blocks.each do |b|
      x = (BLOCK_SIZE * b[0]) + @actor.x
      y = (BLOCK_SIZE * b[1]) + @actor.y

      @actor.image.blit target.screen, [x,y]
    end
  end

end

class Tetromino < Actor

  attr_accessor :image, :blocks

  def setup
    @color ||= "green"
    @image = @resource_manager.load_image "#{@color}.png"

    # Block Offsets to determine how this Tetromino is drawn
    @blocks ||= [ [0,0] ]
  end

end

class SquareView < TetrominoView; end

class Square < Tetromino
  def setup
    @color = "yellow"
    @blocks = [
      [0 , 0], # Our block, bottom right
      [-1, 0], # To the Left
      [-1,-1], # Up and Left
      [0 ,-1]  # Above us
    ]

    super
  end
end

class JView < TetrominoView; end

class J < Tetromino
  def setup
    @color = "dark_blue"
    @blocks = [
      [0 , 0], 
      [0,-1], 
      [1, 0],
      [2, 0]  
    ]

    super
  end
end

class LView < TetrominoView; end

class L < Tetromino
  def setup
    @color = "orange"
    @blocks = [
      [0 , 0], 
      [0,-1], 
      [-1, 0],
      [-2, 0]  
    ]

    super
  end
end

class BarView < TetrominoView; end

class Bar < Tetromino
  def setup
    @color = "light_blue"
    @blocks = [
      [-1, 0], 
      [0, 0], 
      [1, 0],
      [2, 0]  
    ]

    super
  end
end

class TView < TetrominoView; end

class T < Tetromino
  def setup
    @color = "purple"
    @blocks = [
      [0, 0], 
      [-1, 0], 
      [1, 0],
      [0, -1]  
    ]

    super
  end
end

class SView < TetrominoView; end

class S < Tetromino
  def setup
    @color = "green"
    @blocks = [
      [0, 0], 
      [-1, 0], 
      [0, -1],
      [1, -1]  
    ]

    super
  end
end

class ZView < TetrominoView; end

class Z < Tetromino
  def setup
    @color = "red"
    @blocks = [
      [0, 0], 
      [1, 0], 
      [0, -1],
      [-1, -1]  
    ]

    super
  end
end
