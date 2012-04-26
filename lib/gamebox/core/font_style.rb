
class FontStyle
  construct_with :resource_manager

  attr_accessor :font, :name, :size, :color, :x_scale, :y_scale
  def configure(name, size, color, x_scale, y_scale)
    @name = name
    @size = size
    @color = color
    @x_scale = x_scale
    @y_scale = y_scale
    reload
  end
  
  def calc_width(text)
    @font.text_width text
  end
  
  def height
    @font.height
  end
  
  def reload
    @font = resource_manager.load_font name, size
  end
end
