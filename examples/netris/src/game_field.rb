require 'actor'
require 'actor_view'
require 'grid'

class GameFieldView < ActorView
  def draw(target,x_off,y_off)
    x1 = @actor.x - 1 + x_off
    x2 = x1 + @actor.grid.width + 1 + x_off

    y1 = @actor.y - 1 + y_off
    y2 = y1 + @actor.grid.height + 1 + y_off

    # Draw box
    target.draw_box( [x1, y1], [x2, y2], [255,255,255,255] )

    # But hide the top line
    target.draw_line( [x1, y1], [x2, y1], [0, 0, 0, 255] )
  end
end

class GameField < Actor
  has_behaviors :updatable
  attr_accessor :grid

  def setup
    # Drop a row every x milliseconds
    @drop_after = 500

    @grid = Grid.new(10, 21)
    i = @input_manager

    @grid.when(:game_over) do
      puts "Game over man!"
      # TODO nice way to quit a game, or
      # a menu system so we jump back into the menu stage
      exit(0)
    end

    @grid.when(:next_level) do
      puts "Next Level!"
      @drop_after -= 50
    end

    # Setup our key events into the grid
    i.reg KeyPressed, :n do
      @grid.start_play(self)
    end

    i.reg KeyPressed, :space do
      @grid.drop_piece
    end

    i.reg KeyPressed, :left do
      @grid.piece_left
    end

    i.reg KeyPressed, :right do
      @grid.piece_right
    end

    i.reg KeyPressed, :down do
      @grid.piece_down
    end

    i.reg KeyPressed, :up do
      @grid.rotate_piece
    end

    @time_lapsed = 0
  end

  def update(time)
    if @grid.playing?
      @time_lapsed += time

      if @time_lapsed >= @drop_after
        @grid.piece_down
        @time_lapsed = 0
      end
    end

    super
  end

end
