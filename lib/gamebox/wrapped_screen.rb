class WrappedScreen
  constructor :config_manager
  attr_accessor :screen
  def setup
    width, height = @config_manager[:screen_resolution]
    fullscreen = @config_manager[:fullscreen]
    @screen = HookedGosuWindow.new width, height, fullscreen
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
  def draw_circle(cx,cy,r,color)
    c_color = convert_color(color)
    
    0.step(360, CIRCLE_STEP) { |a1| 
      a2 = a1 + CIRCLE_STEP
      @screen.draw_line cx + offset_x(a1, r), cy + offset_y(a1, r), c_color, cx + offset_x(a2, r), cy + offset_y(a2, r), c_color, 0 
    }
  end

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
    a = color.size == 4 ? color[3] : 255
    Gosu::Color.new a.round, *color[0..2].map{|value|value.round}
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
