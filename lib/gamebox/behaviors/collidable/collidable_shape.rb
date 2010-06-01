class CollidableShape
  attr_accessor :opts, :actor, :radius
  def initialize(actor, options)
    @opts = options
    @actor = actor
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
