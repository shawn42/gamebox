module GosuWindowAPI
  MAX_UPDATE_SIZE_IN_MILLIS = 500
  def initialize(width, height, fullscreen)
    super(width, height, fullscreen)
  end

  def update
    millis = Gosu::milliseconds

    # ignore the first update
    if @last_millis
      delta = millis
      delta -= @last_millis if millis > @last_millis
      delta = MAX_UPDATE_SIZE_IN_MILLIS if delta > MAX_UPDATE_SIZE_IN_MILLIS

      fire :update, delta
    end

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

  attr_accessor :needs_cursor
  alias :needs_cursor? :needs_cursor
end

class HookedGosuWindow < Window
  extend Publisher
  include GosuWindowAPI
  can_fire :update, :draw, :button_down, :button_up

end
