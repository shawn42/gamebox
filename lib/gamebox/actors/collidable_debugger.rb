require 'actor'
require 'actor_view'

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
    @color = Color[:white]
  end

  def draw(target,x_off,y_off)
    collider = @actor.actor
    case collider.collidable_shape
    when :circle
      target.draw_circle  [collider.center_x, collider.center_y], collider.radius, @color
    else
      collider.cw_world_lines.each do |line|
        f = line.first
        l = line.last
        target.draw_line [f[0],f[1]],[l[0],l[1]], @color
      end
    end
  end
end
