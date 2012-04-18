


class CollidableDebugger < Actor
  
  attr_reader :actor
  def setup
    @actor = opts[:collider]
    @actor.when :remove_me do
      remove_self
    end

  end
end

class CollidableDebuggerView < ActorView

  def setup
    @color = Color::WHITE
  end

  def draw(target,x_off,y_off,z)
    collider = @actor.actor
    case collider.shape_type
    when :circle
      target.draw_circle x_off+collider.center_x, y_off+collider.center_y, collider.radius, @color, z
    else
      collider.cw_world_lines.each do |line|
        f = line.first
        l = line.last
        target.draw_line x_off+f[0],y_off+f[1],x_off+l[0],y_off+l[1], @color, z
      end
    end
  end
end
