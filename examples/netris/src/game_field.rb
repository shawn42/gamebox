require 'actor'
require 'actor_view'
require 'grid'

class GameFieldView < ActorView
  def draw(target,x_off,y_off)
    x1 = @actor.x - 1 + x_off
    x2 = x1 + @actor.grid.width + 1 + x_off

    y1 = @actor.y - 1 + y_off
    y2 = y1 + @actor.grid.height + 1 + y_off

    target.draw_box( [x1, y1], [x2, y2], [255,255,255,255] )

    # TODO Draw next piece

    # TODO Draw next x pieces?
  end
end

class GameField < Actor

  attr_accessor :grid

  def setup
    # Drop a row every x milliseconds
    @drop_after = 500

    @grid = Grid.new(10, 20)
    i = @input_manager

    # Setup our key events into the grid
    i.reg KeyDownEvent, K_N do
      @grid.start_play(self)
    end

    i.reg KeyDownEvent, K_SPACE do
      @grid.drop_piece
    end

    i.reg KeyDownEvent, K_LEFT do
      @grid.piece_left
    end

    i.reg KeyDownEvent, K_RIGHT do
      @grid.piece_right
    end

    i.reg KeyDownEvent, K_DOWN do
      @grid.piece_down
    end

    i.reg KeyDownEvent, K_UP do
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
