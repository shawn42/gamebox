define_actor :label do
  has_attributes layered: 1
  behavior do
    requires_behaviors :positioned
    requires :font_style_factory

    setup do
      # will define attributes and set their values if no one else has
      actor.has_attributes text:      "",
                           font_size: Gamebox.configuration.default_font_size,
                           font_name: Gamebox.configuration.default_font_name,
                           color:     Gamebox.configuration.default_font_color,
                           width:     0,
                           height:    0,
                           layer:     1

      
      font_style = font_style_factory.build actor.font_name, actor.font_size, actor.color
      actor.has_attributes font_style: font_style

      actor.when :font_size_changed do
        actor.font_style.size = actor.font_size
        actor.font_style.reload
        recalculate_size
      end
      actor.when :font_name_changed do
        actor.font_style.name = actor.font_name
        actor.font_style.reload
        recalculate_size
      end
      actor.when :text_changed do
        recalculate_size
      end
      actor.when :color_changed do
        actor.font_style.color = actor.color
      end

      recalculate_size

    end

    helpers do
      def recalculate_size
        actor.width = actor.font_style.calc_width actor.text
        actor.height = actor.font_style.height
      end
    end
  end

  view do
    draw do |target,x_off,y_off,z|
      target.print actor.text, actor.x, actor.y, z, actor.font_style
    end
  end

end
