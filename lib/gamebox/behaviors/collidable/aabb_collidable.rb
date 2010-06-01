require 'collidable/collidable_shape'

class AaBbCollidable < CollidableShape
  attr_accessor :cw_local_points

  # TODO infinite loop if actor hasn't defined width and it gets relegated to us
  def calculate_radius
    w = @actor.width
    hw = w * 0.5
    h = @actor.height
    hh = h * 0.5
    Math.sqrt(hw*hw+hh*hh)
  end

  def center_x
    @actor.x + @actor.width * 0.5
  end

  def center_y
    @actor.y + @actor.height * 0.5
  end

  def cw_world_points
    @cached_points ||= @cw_local_points.map{|lp| [lp[0]+@actor.x,lp[1]+@actor.y]}
  end

  def cw_world_lines
    return @cached_lines if @cached_lines
    lines = [] 

    hw = @actor.width * 0.5
    hh = @actor.height * 0.5
    lines = [
      [[@actor.x-hw,@actor.y+hh], [@actor.x+hw,@actor.y+hh]],
      [[@actor.x+hw,@actor.y+hh], [@actor.x+hw,@actor.y-hh]],
      [[@actor.x+hw,@actor.y-hh], [@actor.x-hw,@actor.y-hh]],
      [[@actor.x-hw,@actor.y-hh], [@actor.x-hw,@actor.y+hh]]
    ]

    @cached_lines = lines
  end

  def cw_world_edge_normals
    @cached_normals ||= [[1,0],[0,1]]
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
