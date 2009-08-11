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
      :mass => 1,
      :elasticity => 1.0
    }}

end
