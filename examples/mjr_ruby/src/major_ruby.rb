require 'actor'

class MajorRuby < Actor

  has_behavior :animated, :updatable

  attr_accessor :move_left, :move_right, :jump
  def setup
    @speed = 1
    input_manager.while_key_pressed :left, self, :move_left
    input_manager.while_key_pressed :right, self, :move_right
    input_manager.while_key_pressed :up, self, :jump
  end

  def update(time_delta)
    #adjust physics
    if move_right
      @x += @speed * time_delta
      self.action = :move_right
    elsif move_left
      @x -= @speed * time_delta
      self.action = :move_left
    else
      self.action = :idle
    end
  end

end
