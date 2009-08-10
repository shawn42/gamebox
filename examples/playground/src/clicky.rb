require 'actor'
require 'actor_view'

class ClickyView < ActorView
  def draw(target, x_off, y_off)
    x_off = @actor.x + x_off
    y_off = @actor.y + y_off

    if @image.nil?
      @image = Surface.new [101,101], 0, SRCCOLORKEY
      @image.set_colorkey [0,0,0]

      @actor.segment_groups.each do |seg_group|
        seg_group.each_cons(2) do |a,b|
          @image.draw_line [50+a[0],50+a[1]], [50+b[0],50+b[1]], [255,255,255]
        end
      end
    end
    rot_deg = @actor.deg.round % 360
    rot_image = rot_deg == 0 ? @image : @image.rotozoom(rot_deg,1,true) 
    rot_image.set_colorkey [0,0,0]
    w,h = rot_image.size
    rot_image.blit target.screen, [x_off-(w/2).floor, y_off-(h/2).floor]
  end
end

class Clicky < Actor

  has_behaviors :updatable, 
    {:physical => {
      :shape => :poly, :verts => [ [-50,-50], [-50,50], [50,50], [50,-50] ],
      :mass => 1
    }}
  
  def setup
    self.shape.e = 1.0
    i = @input_manager

    @following_mouse = false
    @last_mouse_x = @x
    @last_mouse_y = @y

    i.reg MouseDownEvent do |evt|
      mouse_x = evt.pos[0]
      mouse_y = evt.pos[1]
      bounds = self.shape.bb

      if mouse_x >= bounds.l && mouse_x <= bounds.r &&
        mouse_y >= bounds.b && mouse_y <= bounds.t
        @offset_x = mouse_x - self.x
        @offset_y = mouse_y - self.y
#        puts "mouse [#{mouse_x},#{mouse_y}] : clicky [#{@x},#{@y}]"
        @following_mouse = true
      end
    end

    i.reg MouseMotionEvent do |evt|
      @velocity = vec2((evt.pos[0]-@last_mouse_x) * 1.2, (evt.pos[1]-@last_mouse_y) * 1.2)
      @last_mouse_x = evt.pos[0]
      @last_mouse_y = evt.pos[1]
    end

    i.reg MouseUpEvent do |evt|
      @following_mouse = false
    end
  end

  def update(delta)
    if @following_mouse
      self.warp vec2(@last_mouse_x-@offset_x, @last_mouse_y-@offset_y)
      self.body.v = @velocity * delta
    end
  end
end
