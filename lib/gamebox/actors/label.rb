Behavior.define :label_stuff do
  requires_behaviors :positioned
  requires :font_style_factory

  setup do
    # will define attributes and set their values if no one else has
    actor.has_attributes text:      "",
                         font_size: 30,
                         font_name: "Asimov.ttf",
                         color:     [250,250,250,255],
                         width:     0,
                         height:    0,
                         layer:     1

    
    font_style = font_style_factory.build actor.font_name, actor.font_size, actor.color
    actor.has_attributes font_style: font_style

    actor.when :font_size_changed do
      actor.font_style.reload
      recalculate_size
    end
    actor.when :font_name_changed do
      actor.font_style.reload
      recalculate_size
    end
    actor.when :text_changed do
      recalculate_size
    end

  end

  helpers do
    def recalculate_size
      actor.width = actor.font_style.calc_width actor.text
      actor.height = actor.font_style.height
    end
  end
end

Actor.define :label do
  has_behavior layered: 1
  has_behavior :label_stuff

  view do
    draw do |target,x_off,y_off,z|
      target.print actor.text, actor.x, actor.y, z, actor.font_style
    end
  end

end
