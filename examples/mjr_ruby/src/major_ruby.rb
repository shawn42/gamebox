require 'actor'

class MajorRuby < Actor

  has_behavior :animated, :updatable

  attr_accessor :move_left, :move_right, :jump
  def setup
    @speed = 8
    @gravity = 5
    @map = @opts[:map]
    input_manager.while_key_pressed :left, self, :move_left
    input_manager.while_key_pressed :right, self, :move_right
    input_manager.while_key_pressed :up, self, :jump
  end

  def update(time_delta)
    # TODO sucks that I have to call this here to update my behaviors
    super time_delta
    time_delta = 1

    #adjust physics
    if move_right
      (@speed * time_delta).times do
        move 1, 0
      end
      self.action = :move_right unless self.action == :move_right
    elsif move_left
      (@speed * time_delta).times do
        move -1, 0
      end
      self.action = :move_left unless self.action == :move_left
    elsif jump
      (@speed * 2 * time_delta).times do
        move 0, -1
      end
      self.action = :jump unless self.action == :jump
    else
      self.action = :idle
    end

    (@gravity * time_delta).ceil.times do
      move 0, 1
    end

  end

  def move(dx,dy)
    if would_fit?(dx,0)
      @x += dx 
    end
    if would_fit?(0,dy)
      @y += dy 
    end
  end

  def would_fit?(x_off, y_off)
    not @map.solid? @x.floor+x_off+15, @y.floor+y_off+10 and
      not @map.solid? @x.floor+x_off+45, @y.floor+y_off+50 
  end
end
