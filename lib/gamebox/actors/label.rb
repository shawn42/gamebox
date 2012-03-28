__END__
class LabelView < ActorView
  def draw(target,x_off,y_off,z)
    @converted_color ||= target.convert_color(actor.color)
    actor.font.draw actor.text, actor.x, actor.y, z, 
      1,1,   # x factor, y factor
      @converted_color
  end
end

class Label < Actor
  has_behavior layered: {layer: 1}
  attr_accessor :text, :font, :color

  def setup
    @text = @opts[:text]
    @size = @opts[:size]
    font_name = @opts[:font]
    @color = @opts[:color]

    @text ||= ""
    @size ||= 30
    font_name ||= "Asimov.ttf"
    @color ||= [250,250,250,255]
    layer = opts[:layer] || 1
    layered.layer = layer

    @font = resource_manager.load_font font_name, @size
  end

  def width
    font.text_width(text)
  end

  def height
    [font.text_width(text),font.height]
  end

  def resize(size)
    @size = size
    resource_manager.load_font @font, @size
  end

end
