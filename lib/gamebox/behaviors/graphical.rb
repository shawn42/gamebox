
# keeps track of an image for you based on the actor's class
# by default it expects images to be:
# data/graphics/classname.png
class Graphical < Behavior

  attr_accessor :image, :num_x_tiles, :num_y_tiles, :rotation
  def setup

    @image = @actor.resource_manager.load_actor_image @actor
    @tiled = @opts[:tiled]
    @num_x_tiles = @opts[:num_x_tiles]
    @num_y_tiles = @opts[:num_y_tiles]
    @num_x_tiles ||= 1
    @num_y_tiles ||= 1
    @rotation = 0.0

    graphical_obj = self
    relegates :image, :graphical, :width, :height, :rotation, :rotation=, 
      :scale, :scale=, :x_scale, :y_scale, :x_scale=, :y_scale=
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

  def scale
    @scale || 1
  end

  def scale=(s)
    @scale = s
  end

  def x_scale
    @x_scale || scale
  end

  def x_scale=(xs)
    @x_scale = xs
  end


  def y_scale
    @y_scale || scale
  end

  def y_scale=(ys)
    @y_scale = ys
  end

end
