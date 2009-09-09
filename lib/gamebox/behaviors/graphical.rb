require 'behavior'
# keeps track of an image for you based on the actor's class
# by default it expects images to be:
# data/graphics/classname.png
class Graphical < Behavior

  attr_accessor :image, :num_x_tiles, :num_y_tiles
  def setup

    @image = @actor.resource_manager.load_actor_image @actor
    @tiled = @opts[:tiled]
    @num_x_tiles = @opts[:num_x_tiles]
    @num_y_tiles = @opts[:num_y_tiles]
    @num_x_tiles ||= 1
    @num_y_tiles ||= 1

    graphical_obj = self
    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :image do 
          graphical_obj.image
        end
        define_method :graphical do 
          graphical_obj
        end
      end
    end
  end

  def tiled?
    @tiled
  end

end
