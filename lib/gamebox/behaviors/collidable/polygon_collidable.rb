require 'collidable/collidable_shape'

class PolygonCollidable < CollidableShape
  attr_accessor :cw_local_points

  def setup
    @collidable_shape = opts[:shape]

    @cw_local_points = opts[:cw_local_points]
    @cw_local_points ||= opts[:points]

    @radius = opts[:radius]
    @radius ||= calculate_radius

    @old_x = @actor.x
    @old_y = @actor.y
  end

  def calculate_radius
    local_avg = cw_local_points.inject([0,0]) {|s, (x,y)| s[0] += x; s[1]+=y; s}.map {|x| x / cw_local_points.size}
    max_dist = 0
    cw_local_points.each do |lp|
      x_dist = local_avg[0]-lp[0]
      y_dist = local_avg[1]-lp[1]
      dist = Math.sqrt(x_dist*x_dist + y_dist*y_dist)
      max_dist = dist if dist > max_dist
    end 
    max_dist
  end

  def center_x
    poly_center[0]
  end

  def center_y
    poly_center[1]
  end

  def poly_center
    @cached_poly_center ||= cw_world_points.inject([0,0]) {|s, (x,y)| s[0] += x; s[1]+=y; s}.map {|x| x / cw_world_points.size}
  end

  def cw_world_points
    @cached_points ||= @cw_local_points.map{|lp| [lp[0]+@actor.x,lp[1]+@actor.y]}
  end

  def cw_world_lines
    return @cached_lines if @cached_lines
    lines = [] 

    cw_world_points.each_cons(2) do |a,b|
      lines << [a,b]
    end
    lines << [cw_world_points[-1],cw_world_points[0]]

    @cached_lines = lines
  end

  def cw_world_edge_normals
    return @cached_normals if @cached_normals

    @cached_normals = cw_world_lines.map do |edge|
      # vector subtraction
      v = edge[1][0]-edge[0][0], edge[1][1]-edge[0][1]
      [-v[1],v[0]]
    end

    @cached_normals
  end

  def recalculate_collidable_cache
    unless @old_x == @actor.x && @old_y == @actor.y
      clear_collidable_cache
      @old_x = @actor.x
      @old_y = @actor.y
    end
  end

  def clear_collidable_cache
    @cached_points = nil
    @cached_lines = nil
    @cached_poly_center = nil
  end

end
