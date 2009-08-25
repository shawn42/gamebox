require 'ftor'
include Rubygame::Color
module Rubygame
  class Surface
    def draw_line_s(point1, point2, color, thickness)
      half_thickness = thickness/2.0
      x1 = point1[0]
      y1 = point1[1]
      x2 = point2[0]
      y2 = point2[1]

      point1_vector = Ftor.new x1, y1
      point2_vector = Ftor.new x2, y2

      line_vector = point2_vector-point1_vector
      perp_vector = line_vector.normal.unit

      points = []
      pvt = perp_vector*half_thickness
      poly_point1 = Ftor.new(x1,y1)+pvt
      poly_point2 = Ftor.new(x2,y2)+pvt
      poly_point3 = Ftor.new(x2,y2)-pvt
      poly_point4 = Ftor.new(x1,y1)-pvt

      points << [poly_point1.x,poly_point1.y]
      points << [poly_point2.x,poly_point2.y]
      points << [poly_point3.x,poly_point3.y]
      points << [poly_point4.x,poly_point4.y]
      points << [poly_point1.x,poly_point1.y]

      draw_polygon_s points, color
      draw_circle_s [x1,y1], half_thickness, color
      draw_circle_s [x2,y2], half_thickness, color
    end

    # BY IPPA
    def fill_gradient(user_options = {})
      # merge arguments from methodcall Over default options
      default_options = {  
        :from_color => :black,
        :to_color => :white, 
        :thickness => 10, 
        :orientation => :down, 
        :rect => Rect.new([0, 0, self.width, self.height])
      }
      options = default_options.merge(user_options)

      # typecast color and rect arguments      
      from_color = (options[:from_color].is_a? ColorRGB)? options[:from_color] : Color[options[:from_color]]
      to_color = (options[:to_color].is_a? ColorRGB)? options[:to_color] : Color[options[:to_color]]
      rect = (options[:rect].is_a? Rect)? options[:rect] : Rect.new(:rect)

      length = (options[:orientation] == :vertical) ? rect.height : rect.width
      weight_step = 1.0 / (length.to_f / options[:thickness].to_f)
      weight = 0.0
      x = rect.x
      y = rect.y

      while weight < 1.0 
        color = to_color.average(from_color, weight)

        if options[:orientation] == :vertical
          self.draw_box_s([x, y], [rect.width, y + options[:thickness]], color)
          y += options[:thickness] 
        else
          self.draw_box_s([x, y],[x + options[:thickness], rect.height], color)
          x += options[:thickness]          
        end

        weight += weight_step
      end
    end

  end

end # module Rubygame
