require 'behavior'

class Collidable < Behavior

  attr_accessor :shape, :radius, :width

  def setup
    @shape = opts[:shape]
    @radius = opts[:radius]
    @width = opts[:width]

    collidable_obj = self

    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :shape do |*args|
          collidable_obj.shape *args
        end
        define_method :radius do |*args|
          collidable_obj.radius *args
        end
      end
    end

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
