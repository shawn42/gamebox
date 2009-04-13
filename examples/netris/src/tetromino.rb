require 'actor'
require 'actor_view'

BLOCK_SIZE = 24

class TetrominoView < ActorView

  def draw(target,x_off,y_off)
    @actor.blocks.each do |b|
      x = (BLOCK_SIZE * b[0]) + @actor.x + x_off
      y = (BLOCK_SIZE * b[1]) + @actor.y + x_off

      @actor.image.blit target.screen, [x,y]
    end
  end

end

class Tetromino < Actor

  attr_accessor :image, :blocks, :current_rotation

  def setup
    @color ||= "green"
    @image = @resource_manager.load_image "#{@color}.png"

    # Block Offsets to determine how this Tetromino is drawn
    @blocks ||= [ [ [0,0] ] ]
    @current_rotation = 0
  end

  def blocks
    @blocks[@current_rotation]
  end

  def rotate
    @current_rotation = (@current_rotation + 1) % @blocks.length
  end

  # For undoing a rotation, for example in the case where a rotation causes a collision
  def rotate_back
    @current_rotation = (@current_rotation - 1) % @blocks.length
  end

  # Boundry calculations. Due to the rotations of these pieces,
  # the boundries of tetrominos changes. The following calculate
  # the x and y positions of the boundries of this piece

  def left_boundry
    left = 9999
    x = self.x
    self.blocks.each do |block|
      block_pos = block[0] * BLOCK_SIZE + x
      left = block_pos if block_pos < left
    end

    left
  end

  def right_boundry
    right = 0
    x = self.x + BLOCK_SIZE
    self.blocks.each do |block|
      block_pos = block[0] * BLOCK_SIZE + x
      right = block_pos if block_pos > right
    end

    right
  end

  def bottom_boundry
    bottom = 0
    y = self.y + BLOCK_SIZE
    self.blocks.each do |block|
      block_pos = block[1] * BLOCK_SIZE + y
      bottom = block_pos if block_pos > bottom
    end

    bottom
  end

end

class SquareView < TetrominoView; end

class Square < Tetromino
  def setup
    @color = "yellow"
    @blocks = [ [
      [0, 0],
      [1, 0],
      [1, -1],
      [0, -1]
    ] ]

    super
  end
end

class JView < TetrominoView; end

class J < Tetromino
  def setup
    @color = "dark_blue"
    @blocks = [[
      [0 , 0],
      [0,-1],
      [1, 0],
      [2, 0]
    ], [
      [0 , 0],
      [1, 0],
      [0, 1],
      [0, 2]
    ], [
      [0 , 0],
      [-1, 0],
      [-2, 0],
      [0, 1]
    ], [
      [0 , 0],
      [0, -1],
      [0, -2],
      [-1, 0]
    ]]

    super
  end
end

class LView < TetrominoView; end

class L < Tetromino
  def setup
    @color = "orange"
    @blocks = [ [
      [0 , 0],
      [0,-1],
      [-1, 0],
      [-2, 0]
    ], [
      [0 , 0],
      [1, 0],
      [0, -1],
      [0, -2]
    ], [
      [0 , 0],
      [1, 0],
      [2, 0],
      [0, 1]
    ], [
      [0 , 0],
      [-1, 0],
      [0, 1],
      [0, 2]
    ]]

    super
  end
end

class BarView < TetrominoView; end

class Bar < Tetromino
  def setup
    @color = "light_blue"
    @blocks = [[
      [-1, 0],
      [0, 0],
      [1, 0],
      [2, 0]
    ],[
      [0, -2],
      [0, -1],
      [0, 0],
      [0, 1]
    ]]

    super
  end
end

class TView < TetrominoView; end

class T < Tetromino
  def setup
    @color = "purple"
    @blocks = [[
      [0, 0],
      [-1, 0],
      [1, 0],
      [0, -1]
    ],[
      [0, 0],
      [0, -1],
      [1, 0],
      [0, 1]
    ],[
      [0, 0],
      [-1, 0],
      [1, 0],
      [0, 1]
    ],[
      [0, 0],
      [0, -1],
      [0, 1],
      [-1, 0]
    ]]

    super
  end
end

class SView < TetrominoView; end

class S < Tetromino
  def setup
    @color = "green"
    @blocks = [[
      [0, 0],
      [-1, 0],
      [0, -1],
      [1, -1]
    ], [
      [0, 0],
      [0, 1],
      [-1, 0],
      [-1, -1]
    ]]

    super
  end
end

class ZView < TetrominoView; end

class Z < Tetromino
  def setup
    @color = "red"
    @blocks = [[
      [0, 0],
      [1, 0],
      [0, -1],
      [-1, -1]
    ], [
      [0, 0],
      [0, 1],
      [1, 0],
      [1, -1]
    ]]

    super
  end
end
