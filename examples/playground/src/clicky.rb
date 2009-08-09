require 'actor'
require 'actor_view'

class ClickyView < ActorView
  def draw(target, x_off, y_off)
    x_off = (@actor.x + x_off).floor
    y_off = (@actor.y + y_off).floor
    @actor.segment_groups.each do |seg_group|
#      p seg_group

      seg_group.each_cons(2) do |a,b|
#        p "drawing #{a.inspect} -> #{b.inspect} "
        target.draw_line [a[0]+x_off,a[1]+y_off], [b[0]+x_off,b[1]+y_off], [255,255,255,255]
      end

#      seg_group.each do |seg|
#        p seg
#        p1 = seg[0]
#        p2 = seg[1]
#        puts "p1: #{p1.inspect} p2: #{p2.inspect} xoff: #{x_off.inspect} yoff: #{y_off.inspect} "
#        puts "#{p1[0]+x_off},#{p1[1]+y_off} to #{p2[0]+x_off},#{p2[1]+y_off}"
#        target.draw_line [p1[0]+x_off,p1[1]+y_off], [p2[0]+x_off,p2[1]+y_off], [255,255,255,255]
##        target.draw_line_s [p1[0]+x_off,p1[1]+y_off], [p2[0]+x_off,p2[1]+y_off], [25,255,25,255], 6
#      end
    end
  end
end

class Clicky < Actor

  has_behaviors :updatable, 
    {:physical => {
      :shape => :poly, :verts => [ [-50,-50], [-50,50], [50,50], [50,-50] ],
      :mass => 1
    }}
  
  def setup
    i = @input_manager

    @following_mouse = false
    @last_mouse_x = @x
    @last_mouse_y = @y

    i.reg MouseDownEvent do |evt|
      puts "Mouse down"
      mouse_x = evt.pos[0]
      mouse_y = evt.pos[1]
      bounds = self.shape.bb

      puts "Bounds: #{bounds.inspect}. Event: #{evt.inspect}"

      if mouse_x >= bounds.l && mouse_x <= bounds.r &&
        mouse_y >= bounds.b && mouse_y <= bounds.t
        puts "GOT YOU!"
        @following_mouse = true
      end
    end

    i.reg MouseMotionEvent do |evt|
      @last_mouse_x = evt.pos[0]
      @last_mouse_y = evt.pos[1]
    end

    i.reg MouseUpEvent do |evt|
      @following_mouse = false
    end
  end

  def update(delta)
    if @following_mouse
      self.warp vec2(@last_mouse_x, @last_mouse_y)
      self.body.v = ZeroVec2
    end
  end
end
