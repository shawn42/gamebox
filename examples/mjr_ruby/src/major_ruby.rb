require 'actor'

class MajorRuby < Actor
  
  has_behavior :animated, :updatable

  def setup
    input_manager.reg KeyDownEvent, :left do
    end
    input_manager.reg KeyDownEvent, :right do
    end
    input_manager.reg KeyDownEvent, :up do
    end
  end

  def update(time_delta)
    #adjust physics
  end

end
