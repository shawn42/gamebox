class CollidableShape
  attr_accessor :opts, :actor, :radius
  def initialize(actor, options)
    @opts = options
    @actor = actor

    @x_offset = opts[:x_offset]
    @y_offset = opts[:y_offset]
    @x_offset ||= 0
    @y_offset ||= 0
  end

  def actor_x
    @actor.x + @x_offset
  end

  def actor_y
    @actor.y + @y_offset
  end

  def setup
  end

  def width
    @radius * 2
  end
  alias :height :width

  def update(time)
    recalculate_collidable_cache
  end

  def recalculate_collidable_cache
  end
end
