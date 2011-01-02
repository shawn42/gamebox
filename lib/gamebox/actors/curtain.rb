require 'actor'
require 'publisher'
require 'actor_view'

class CurtainView < ActorView
  def draw(target,x_off,y_off,z)
    target.fill 0,0,1024,800, [0,0,0,@actor.height], z
  end
end

class Curtain < Actor
  extend Publisher

  can_fire :curtain_up, :curtain_down

  has_behavior :updatable, :layered => {:layer => 99_999}

  attr_accessor :height

  FULL_CURTAIN = 255
  NO_CURTAIN = 0
  def setup
    @duration_in_ms = @opts[:duration]
    @duration_in_ms ||= 1000

    case @opts[:dir]
    when :up
      @height = FULL_CURTAIN
      @dir = -1
    when :down
      @height = NO_CURTAIN
      @dir = 1
    end
  end

  # Update curtain height 0-255 (alpha)
  def update(time)
    perc_change = time.to_f/@duration_in_ms
    amount = FULL_CURTAIN * perc_change * @dir
    @height += amount.floor

    if @height < 0
      @height = 0
      if alive?
        fire :curtain_up
        remove_self
      end
    elsif @height > 255
      @height = 255
      if alive?
        fire :curtain_down
        remove_self
      end
    end

  end
end
