require 'behavior'

# available collidable_shapes are :circle, :polygon, :aabb
class Collidable < Behavior

  attr_accessor :collidable_shape, :radius, :width, :cw_local_points

  def setup
    @collidable_shape = opts[:shape]
    @width = opts[:width]

    @cw_local_points = opts[:cw_local_points]
    @cw_local_points ||= opts[:points]

    @radius = opts[:radius]
    @radius ||= calculate_radius

    @old_x = @actor.x
    @old_y = @actor.y

    relegates :collidable_shape, :radius, :cw_world_points, :cw_world_lines, :center_x, :center_y
    register_actor
  end

  def calculate_radius
    case @collidable_shape
    when :circle
      @actor.respond_to? :width ? @actor.width : 1
    when :aabb
      w = @actor.respond_to? :width ? @actor.width : 1
      hw = w * 0.5
      h = @actor.respond_to? :height ? @actor.height : 1
      hh = h * 0.5
      Math.sqrt(hw*hw+hh*hh)
    when :polygon
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
  end

  def center_x
    case @collidable_shape
    when :circle
      @actor.x + radius
    when :aabb
      w = @actor.respond_to? :width ? @actor.width : 1
      @actor.x + w * 0.5
    when :polygon
      poly_center[0]
    end
  end

  def center_y
    case @collidable_shape
    when :circle
      @actor.y + radius
    when :aabb
      h = @actor.respond_to? :height ? @actor.height : 1
      @actor.y + h * 0.5
    when :polygon
      poly_center[1]
    end
  end

  def register_actor
    @actor.stage.register_collidable @actor
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

    case @collidable_shape
    when :aabb
      w = @actor.respond_to? :width ? @actor.width : 1
      hw = w * 0.5
      h = @actor.respond_to? :height ? @actor.height : 1
      hh = h * 0.5
      lines = [
        [[@actor.x-hw,@actor.y+hh], [@actor.x+hw,@actor.y+hh]],
        [[@actor.x+hw,@actor.y+hh], [@actor.x+hw,@actor.y-hh]],
        [[@actor.x+hw,@actor.y-hh], [@actor.x-hw,@actor.y-hh]],
        [[@actor.x-hw,@actor.y-hh], [@actor.x-hw,@actor.y+hh]]
      ]
    when :polygon
      cw_world_points.each_cons(2) do |a,b|
        lines << [a,b]
      end
      lines << [cw_world_points[-1],cw_world_points[0]]
    end

    @cached_lines = lines
  end

  def cw_world_edge_normals
    return @cached_normals if @cached_normals

    case @collidable_shape
    when :aabb
      @cached_normals = [[1,0],[0,1]]
    when :polygon
      @cached_normals = cw_world_lines.map do |edge|
        # vector subtraction
        v = edge[1][0]-edge[0][0], edge[1][1]-edge[0][1]
        [-v[1],v[0]]
      end
    end

    @cached_normals
  end

  def recalculate_collibable_cache
    unless @old_x == @actor.x && @old_y == @actor.y
      clear_collidable_cache
      @old_x = @actor.x
      @old_y = @actor.y
    end
  end

  def clear_collidable_cache
    @cached_points = nil
    @cached_lines = nil
    # these don't change unless the polygon changes shape
#    @cached_normals = nil
    @cached_poly_center = nil
  end

end
