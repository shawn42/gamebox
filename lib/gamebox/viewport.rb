# Viewport represents the current "camera" location.  Essensially it translates from
# world to screen coords and from screen coords to world coords.
class Viewport
  extend Publisher
  can_fire :scrolled
  
  attr_accessor :x_offset, :y_offset, :follow_target, :width,
    :height, :x_offset_range, :y_offset_range, :boundary

  attr_reader :speed

  def debug
    "xoff:#{@x_offset} yoff:#{@y_offset}"
  end

  def initialize(width, height)
    @speed = 1
    @x_offset = 0
    @y_offset = 0

    @width = width
    @height = height
  end

  def scroll(x_delta,y_delta)
    @x_offset += x_delta
    @y_offset += y_delta

    fire :scrolled
  end

  def speed=(new_speed)
    if new_speed > 1
      @speed = 1
    elsif new_speed < 0
      @speed = 0
    else
      @speed = new_speed
    end
  end

  def x_offset(layer=1)
    return 0 if layer == Float::INFINITY
    return @x_offset if layer == 1
    @x_offset / layer
  end

  def y_offset(layer=1)
    return 0 if layer == Float::INFINITY
    return @y_offset if layer == 1
    @y_offset / layer
  end

  def update(time)
    scrolled = false
    if @follow_target
      x = @follow_target.x
      y = @follow_target.y
      if @x_offset_range
        x = @x_offset_range.min if @x_offset_range.min > x 
        x = @x_offset_range.max if @x_offset_range.max < x 
      end
      if @y_offset_range
        y = @y_offset_range.min if @y_offset_range.min > y 
        y = @y_offset_range.max if @y_offset_range.max < y 
      end
      x_diff = @width/2 + @follow_offset_x - x - @x_offset
      if x_diff.abs > @buffer_x
        # move screen 
        if x_diff > 0
          @x_offset += (x_diff - @buffer_x) * @speed
        else
          @x_offset += (x_diff + @buffer_x) * @speed
        end

        scrolled = true
      end


      y_diff = @height/2 + @follow_offset_y - y - @y_offset
      if y_diff.abs > @buffer_y
        # move screen
        if y_diff > 0
          @y_offset += (y_diff - @buffer_y) * @speed
        else
          @y_offset += (y_diff + @buffer_y) * @speed
        end
        scrolled = true
      end

      # constrain_x_offset
      if @boundary
        if @x_offset > 0 - @boundary[0] # Left-wall bump
          @x_offset = @boundary[0]
        elsif @x_offset < @width - @boundary[2] # right-wall bump
          @x_offset = @width - @boundary[2]
        end
      end

      # constrain_y_offset
      if @boundary
        if @y_offset > 0 - @boundary[1]
          @y_offset = @boundary[1]
        elsif @y_offset < @height - @boundary[3]
          @y_offset = @height - @boundary[3]
        end
      end

      fire :scrolled if scrolled
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

    fire :scrolled
  end

  def bounds
    left = -@x_offset
    top = -@y_offset
    Rect.new left, top, left + @width, top + @height
  end

end
