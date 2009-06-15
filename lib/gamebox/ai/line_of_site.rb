# LineOfSite is a class for finding neighbors in a map that are visible
class LineOfSite
  def initialize(map)
    @map = map
  end
  
  def losline(x, y, x2, y2)
    brensenham_line(x, y, x2, y2).each do |i|
      iterx, itery = *i
      occ = @map.occupant(loc2(iterx,itery))
      return unless occ
      occ.lit = true
      occ.seen = true
      
      return if occ.solid?      
    end
  end            
  
  # Brensenham line algorithm
  def brensenham_line(x,y,x2,y2)
    steep = false
    coords = []
    dx = (x2 - x).abs
    if (x2 - x) > 0
      sx = 1
    else 
      sx = -1
    end
    dy = (y2 - y).abs
    if (y2 - y) > 0
      sy = 1
    else
      sy = -1
    end
    if dy > dx
      steep = true
      x,y = y,x
      dx,dy = dy,dx
      sx,sy = sy,sx
    end
    d = (2 * dy) - dx

    dx.times do
      if steep 
        coords << [y,x]
      else
        coords << [x,y]
      end
      while d >= 0
        y = y + sy
        d = d - (2 * dx)
      end
      x = x + sx
      d = d + (2 * dy)
    end
    coords << [x2,y2]
    
    coords             
  end  

end