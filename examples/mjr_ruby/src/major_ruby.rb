require 'actor'

class MajorRuby < Actor

  has_behavior :animated, :updatable

  def setup
    @speed = 5
    # TODO add the while button down idea...
    input_manager.reg KeyPressed, :left do
      @move_left = true 
    end
    input_manager.reg KeyPressed, :right do
      @move_right = true 
    end
    input_manager.reg KeyPressed, :up do
      @jump = true
    end
    input_manager.reg KeyReleased, :left do
      @move_left = false 
    end
    input_manager.reg KeyReleased, :right do
      @move_right = false 
    end
    input_manager.reg KeyReleased, :up do
      @jump = false
    end
  end

  def update(time_delta)
    #adjust physics
    if @move_right
      @x += @speed 
      self.action = :right
    elsif @move_left
      @x -= @speed 
      self.action = :left
    else
      self.action = :idle
    end
  end

end
