# Viewport represents the current "camera" location.  Essensially it translates from
# world to screen coords and from screen coords to world coords.
class Viewport
  attr_accessor :x_offset, :y_offset, :follow_target, :width,
    :height

  def debug
    "xoff:#{@x_offset} yoff:#{@y_offset}"
  end

  def initialize(width, height)
    @x_offset = 0
    @y_offset = 0

    @width = width
    @height = height
  end

  def x_offset(layer=1)
    return 0 if layer == Float::Infinity
    return @x_offset if layer == 1
    @x_offset / layer
  end

  def y_offset(layer=1)
    return 0 if layer == Float::Infinity
    return @y_offset if layer == 1
    @y_offset / layer
  end

  def update(time)
    if @follow_target
      x_diff = @width/2 + @follow_offset_x - @follow_target.x - @x_offset
      if x_diff.abs > @buffer_x
        # move screen
        if x_diff > 0
          @x_offset += x_diff - @buffer_x 
        else
          @x_offset += x_diff + @buffer_x 
        end
      end

      y_diff = @height/2 + @follow_offset_y - @follow_target.y - @y_offset
      if y_diff.abs > @buffer_y
        # move screen
        if y_diff > 0
          @y_offset += y_diff - @buffer_y 
        else
          @y_offset += y_diff + @buffer_y 
        end
      end

    end
  end

  def follow(target, off=[0,0], buff=[0,0])
    @follow_target = target
    @follow_offset_x = off[0]
    @follow_offset_y = off[1]
    @buffer_x = buff[0]
    @buffer_y = buff[1]

    @x_offset = @width/2 - @follow_target.x + @follow_offset_x
    @y_offset = @height/2 - @follow_target.y + @follow_offset_y
  end

end
