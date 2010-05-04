require 'behavior'

class Collidable < Behavior

  attr_accessor :collidable_shape, :radius, :width

  def setup
    @collidable_shape = opts[:shape]
    @radius = opts[:radius]
    @width = opts[:width]

    relegates :collidable_shape, :radius
    register_actor
  end

  def register_actor
    @actor.stage.register_collidable @actor
  end

  def bounding_box
    [ @actor.x-@width,@actor.y-@width,
      @actor.x+@width,@actor.y+@width ]
  end

  def bounding_circle
    [ @actor.x+@radius, @actor.y+@radius, @radius]
  end

end
