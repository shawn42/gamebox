require 'actor'
require 'actor_view'

BLOCK_SIZE = 24

##
## Actor and View definitions for individual blocks
##
class BlockView < ActorView
  def draw(target, x_off, y_off)
    x = @actor.x + x_off
    y = @actor.y + x_off

    @actor.image.blit target.screen, [x,y]
  end
end

class Block < Actor
  attr_accessor :image, :grid_offset_x, :grid_offset_y
end

##
## Actor and View defintions of the full Tetrominos
##
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

  attr_accessor :image, :blocks, :current_rotation, :grid_position

  def setup
    @color ||= "green"
    @image = @resource_manager.load_image "#{@color}.png"

    # Block Offsets to determine how this Tetromino is drawn
    @blocks ||= [ [ [0,0] ] ]
    @current_rotation = 0

    # grid_position is this block's current position in the grid
    # This grid_position is linked to the core rotation block
    # of this tetromino (the [0,0] block)
    @grid_position = Struct.new(:x, :y).new(0, 0)
  end

  # When the piece is done falling, build up block
  def build_blocks
    new_blocks = []
    self.blocks.each do |block|
      actor = spawn :block
      actor.x = block[0] * BLOCK_SIZE + self.x
      actor.y = block[1] * BLOCK_SIZE + self.y
      actor.grid_offset_x = block[0]
      actor.grid_offset_y = block[1]
      actor.image = self.image

      new_blocks << actor
    end

    # Destroy ourselves, leaving only the blocks behind
    remove_self

    new_blocks
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
