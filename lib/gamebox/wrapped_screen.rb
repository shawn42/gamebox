class WrappedScreen
  constructor :config_manager
  attr_accessor :screen
  def setup
    width, height = *@config_manager[:screen_resolution]
    fullscreen = @config_manager[:fullscreen]
    @screen = HookedGosuWindow.new width, height, fullscreen
    @screen.caption = @config_manager[:title]
  end

  def method_missing(name,*args)
    @screen.send name, *args
  end

  def width
    @screen.width
  end

  def height
    @screen.height
  end

  def draw_box(x1,y1,x2,y2,color, z)
    c = convert_color(color)
    @screen.draw_line x1, y1, c, x2, y1, c, z
    @screen.draw_line x2, y1, c, x2, y2, c, z
    @screen.draw_line x2, y2, c, x1, y2, c, z
    @screen.draw_line x1, y2, c, x1, y1, c, z
  end

  def draw_line(x1,y1,x2,y2,color, z)
    c = convert_color(color)
    @screen.draw_line x1, y1, c, x2, y2, c, z
  end

  CIRCLE_STEP = 10
  # is very expensive
  # cache it if you can somehow
  def draw_circle(cx,cy,r,color, z, step=CIRCLE_STEP)
    c_color = convert_color(color)
    
    x1, y1 = 0, -r
    circ = 2 * Math::PI * r
    step = 360 / circ
    step.step(45, step) { |a|
      x2, y2 = offset_x(a, r), offset_y(a, r)
      @screen.draw_line cx + x1, cy + y1, c_color, cx + x2, cy + y2, c_color, z
      @screen.draw_line cx - x1, cy + y1, c_color, cx - x2, cy + y2, c_color, z
      @screen.draw_line cx - x1, cy - y1, c_color, cx - x2, cy - y2, c_color, z
      @screen.draw_line cx + x1, cy - y1, c_color, cx + x2, cy - y2, c_color, z
      @screen.draw_line cx + y1, cy + x1, c_color, cx + y2, cy + x2, c_color, z
      @screen.draw_line cx - y1, cy + x1, c_color, cx - y2, cy + x2, c_color, z
      @screen.draw_line cx - y1, cy - x1, c_color, cx - y2, cy - x2, c_color, z
      @screen.draw_line cx + y1, cy - x1, c_color, cx + y2, cy - x2, c_color, z
      x1, y1 = x2, y2
    }
    @screen.draw_line cx + x1, cy + y1, c_color, cx - y1, cy - x1, c_color, z
    @screen.draw_line cx - x1, cy + y1, c_color, cx + y1, cy - x1, c_color, z
    @screen.draw_line cx - x1, cy - y1, c_color, cx + y1, cy + x1, c_color, z
    @screen.draw_line cx + x1, cy - y1, c_color, cx - y1, cy + x1, c_color, z
  end

  # is very expensive
  # cache it if you can somehow
  def draw_circle_filled(cx,cy,r,color, z)
    c_color = convert_color(color)

    x1, y1 = 0, -r
    circ = 2 * Math::PI * r
    step = 360 / circ
    step.step(45, step) { |a|
      x2, y2 = offset_x(a, r), offset_y(a, r)
      @screen.draw_quad \
        cx + x1, cy + y1, c_color, cx + x2, cy + y2, c_color,
        cx - x2, cy + y2, c_color, cx - x1, cy + y1, c_color, z
      @screen.draw_quad \
        cx - x1, cy - y1, c_color, cx - x2, cy - y2, c_color,
        cx + x2, cy - y2, c_color, cx + x1, cy - y1, c_color, z
      @screen.draw_quad \
        cx + y1, cy + x1, c_color, cx + y2, cy + x2, c_color,
        cx - y2, cy + x2, c_color, cx - y1, cy + x1, c_color, z
      @screen.draw_quad \
        cx - y1, cy - x1, c_color, cx - y2, cy - x2, c_color,
        cx + y2, cy - x2, c_color, cx + y1, cy - x1, c_color, z
      x1, y1 = x2, y2
    }
    @screen.draw_quad \
      cx + x1, cy + y1, c_color, cx - y1, cy - x1, c_color,
      cx + y1, cy - x1, c_color, cx - x1, cy + y1, c_color, z
    @screen.draw_quad \
      cx - x1, cy - y1, c_color, cx + y1, cy + x1, c_color,
      cx - y1, cy + x1, c_color, cx + x1, cy - y1, c_color, z
  end

  def fill_screen(color, z)
    c = convert_color(color)
    @screen.draw_quad 0, 0, c, @screen.width, 0, c, 0, @screen.height, c, @screen.width, @screen.height, c, z
  end

  def fill(x1,y1,x2,y2,color, z)
    c = convert_color(color)
    @screen.draw_quad x1, y1, c, x2, y1, c, x1, y2, c, x2, y2, c, z
  end

  def convert_color(color)
    @colors ||= {}
    c = @colors[color]
    if c.nil?
      a = color.size == 4 ? color[3] : 255
      c = Gosu::Color.new a.round, *color[0..2].map{|value|value.round}
      @colors[color] = c
    end
    c
  end

  def size_text(text, font_file, font_size)
    @font_cache ||= {}
    @font_cache[font_file] ||= {}
    font = @font_cache[font_file][font_size] ||= Font.new(@screen, font_file, font_size)

    return [font.text_width(text),font.height]
  end

  def render_text(text, font_file, font_size, color)
    @font_cache ||= {}
    @font_cache[font_file] ||= {}
    font = @font_cache[font_file][font_size] ||= Font.new(@screen, font_file, font_size)

    DelayedText.new font, text
  end
end
