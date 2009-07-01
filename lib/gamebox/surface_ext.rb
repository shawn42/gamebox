require 'rubygame'
require 'ftor'
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
  end

end # module Rubygame
