require 'actor'

class Clicky < Actor

  has_behaviors :updatable, 
    :graphical,
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
