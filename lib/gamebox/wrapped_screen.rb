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

  def draw_box(x1,y1,x2,y2,color)
    c = convert_color(color)
    @screen.draw_line x1, y1, c, x2, y1, c
    @screen.draw_line x2, y1, c, x2, y2, c
    @screen.draw_line x2, y2, c, x1, y2, c
    @screen.draw_line x1, y2, c, x1, y1, c
  end

  def draw_line(x1,y1,x2,y2,color)
    c = convert_color(color)
    @screen.draw_line x1, y1, c, x1, y2, c
  end

  CIRCLE_STEP = 10
  # is very expensive
  # cache it if you can somehow
  def draw_circle(cx,cy,r,color)
    c_color = convert_color(color)
    
    x1, y1 = 0, -r
    circ = 2 * Math::PI * r
    step = 360 / circ
    step.step(45, step) { |a|
      x2, y2 = offset_x(a, r), offset_y(a, r)
      @screen.draw_line cx + x1, cy + y1, c_color, cx + x2, cy + y2, c_color, 0
      @screen.draw_line cx - x1, cy + y1, c_color, cx - x2, cy + y2, c_color, 0
      @screen.draw_line cx - x1, cy - y1, c_color, cx - x2, cy - y2, c_color, 0
      @screen.draw_line cx + x1, cy - y1, c_color, cx + x2, cy - y2, c_color, 0
      @screen.draw_line cx + y1, cy + x1, c_color, cx + y2, cy + x2, c_color, 0
      @screen.draw_line cx - y1, cy + x1, c_color, cx - y2, cy + x2, c_color, 0
      @screen.draw_line cx - y1, cy - x1, c_color, cx - y2, cy - x2, c_color, 0
      @screen.draw_line cx + y1, cy - x1, c_color, cx + y2, cy - x2, c_color, 0
      x1, y1 = x2, y2
    }
    @screen.draw_line cx + x1, cy + y1, c_color, cx - y1, cy - x1, c_color, 0
    @screen.draw_line cx - x1, cy + y1, c_color, cx + y1, cy - x1, c_color, 0
    @screen.draw_line cx - x1, cy - y1, c_color, cx + y1, cy + x1, c_color, 0
    @screen.draw_line cx + x1, cy - y1, c_color, cx - y1, cy + x1, c_color, 0
  end

  # is very expensive
  # cache it if you can somehow
  def draw_circle_filled(cx,cy,r,color)
    c_color = convert_color(color)

    0.step(360, CIRCLE_STEP) { |a1| 
      a2 = a1 + CIRCLE_STEP
      @screen.draw_triangle cx + offset_x(a1, r), cy + offset_y(a1, r), c_color, cx + offset_x(a2, r), cy + offset_y(a2, r), c_color, cx, cy, c_color, 0 
    }
  end

  def fill_screen(color)
    c = convert_color(color)
    @screen.draw_quad 0, 0, c, @screen.width, 0, c, 0, @screen.height, c, @screen.width, @screen.height, c
  end

  def fill(x1,y1,x2,y2,color)
    c = convert_color(color)
    @screen.draw_quad x1, y1, c, x2, y1, c, x1, y2, c, x2, y2, c
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

    # TODO how do you set the color here?
#      text_image = Image.from_text(@screen, text, font_file, font_size, 2, font.text_width(text).ceil, :left)
    DelayedText.new font, text
#      text_image = font.draw(text, 0, 0, 1)
  end
end
