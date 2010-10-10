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
    relegates :image, :graphical, :width, :height
  end

  def graphical
    self
  end

  def width
    image.width
  end

  def height
    image.height
  end

  def tiled?
    @tiled
  end

end
