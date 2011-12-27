require 'publisher'

class HookedGosuWindow < Window
  extend Publisher
  can_fire :update, :draw, :button_down, :button_up

  attr_accessor :needs_cursor
  alias :needs_cursor? :needs_cursor

  def initialize(width, height, fullscreen)
    super(width, height, fullscreen)
  end

  def update
    millis = Gosu::milliseconds
    @last_millis ||= 0
    fire :update, (millis - @last_millis)
    @last_millis = millis
  end

  def draw
    fire :draw
  end

  # in gosu this captures mouse and keyboard events
  def button_down(id)
    fire :button_down, id
  end

  def button_up(id)
    fire :button_up, id
  end
end
