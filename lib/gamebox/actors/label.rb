class LabelView < ActorView
  def draw(target,x_off,y_off)
    actor.text_image.blit target.screen, [actor.x, actor.y]
  end
end
class Label < Actor
  attr_accessor :text, :text_image

  def setup
    @text = @opts[:text]
    @size = @opts[:size]
    @font = @opts[:font]
    @color = @opts[:color]

    @text ||= ""
    @size ||= 30
    @font ||= "Asimov.ttf"
    @color ||= [250,250,250,255]

    font = resource_manager.load_font @font, @size
    @text_image = font.render @text.to_s, true, @color
  end
end
