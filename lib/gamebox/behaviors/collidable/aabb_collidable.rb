

class AaBbCollidable < CollidableShape
  attr_accessor :cw_local_points

  def setup
    @shape_type = opts[:shape]

    @cw_local_points = opts[:cw_local_points]
    @cw_local_points ||= opts[:points]
    @cw_world_points ||= build_aabb

    @radius = opts[:radius]
    @radius ||= calculate_radius

    @old_x = actor_x
    @old_y = actor_y
  end

  def build_aabb
    w = @actor.width
    h = @actor.height
    [
      [0,0],
      [w,0],
      [w,h],
      [0,h]
    ]
  end

  # TODO infinite loop if actor hasn't defined width and it gets relegated to us
  def calculate_radius
    w = @actor.width
    hw = w * 0.5
    h = @actor.height
    hh = h * 0.5
    Math.sqrt(hw*hw+hh*hh)
  end

  def center_x
    actor_x + @actor.width * 0.5
  end

  def center_y
    actor_y + @actor.height * 0.5
  end

  def cw_world_points
    @cached_points ||= @cw_local_points.map{|lp| [lp[0]+actor_x,lp[1]+actor_y]}
  end

  def cw_world_lines
    return @cached_lines if @cached_lines
    lines = [] 

    hw = @actor.width * 0.5
    hh = @actor.height * 0.5
    lines = [
      [[actor_x-hw,actor_y+hh], [actor_x+hw,actor_y+hh]],
      [[actor_x+hw,actor_y+hh], [actor_x+hw,actor_y-hh]],
      [[actor_x+hw,actor_y-hh], [actor_x-hw,actor_y-hh]],
      [[actor_x-hw,actor_y-hh], [actor_x-hw,actor_y+hh]]
    ]

    @cached_lines = lines
  end

  def cw_world_edge_normals
    @cached_normals ||= [[1,0],[0,1]]
  end

  def recalculate_collidable_cache
    unless @old_x == actor_x && @old_y == actor_y
      clear_collidable_cache
      @old_x = actor_x
      @old_y = actor_y
    end
  end

  def clear_collidable_cache
    @cached_points = nil
    @cached_lines = nil
    @cached_poly_center = nil
  end

end
