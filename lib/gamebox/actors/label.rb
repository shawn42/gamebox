class LabelView < ActorView
  def draw(target,x_off,y_off,z)
    actor.font.draw actor.text, actor.x, actor.y, z
  end
end
class Label < Actor
  attr_accessor :text, :font

  def setup
    @text = @opts[:text]
    @size = @opts[:size]
    font = @opts[:font]
    @color = @opts[:color]

    @text ||= ""
    @size ||= 30
    font ||= "Asimov.ttf"
    @color ||= [250,250,250,255]

    @font = resource_manager.load_font font, @size
  end
end
