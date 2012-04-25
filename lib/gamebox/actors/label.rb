Behavior.define :label_stuff do
  requires_behaviors :positioned
  requires :resource_manager

  setup do
    # will define attributes and set their values if no one else has
    actor.has_attributes text:      "", 
                         font_name: "Asimov.ttf",
                         color:     [250,250,250,255],
                         font_size: 30,
                         width:     0,
                         height:    0,
                         layer:     1

    font = resource_manager.load_font actor.font_name, actor.font_size
    actor.has_attributes font: font

    actor.when :font_size_changed do
      actor.font = resource_manager.load_font actor.font_name, actor.font_size
    end
    actor.when :font_name_changed do
      actor.font = resource_manager.load_font actor.font_name, actor.font_size
    end
    actor.when :text_changed do
      actor.width = actor.font.text_width actor.text
      actor.height = [actor.width, font.height]
    end

  end

end

Actor.define :label do
  has_behavior layered: 1
  has_behavior :label_stuff

  view do
    draw do |target,x_off,y_off,z|
      @converted_color ||= target.convert_color(actor.color)
      actor.font.draw actor.text, actor.x, actor.y, z, 
        1,1,   # x factor, y factor
        @converted_color
    end
  end

end
