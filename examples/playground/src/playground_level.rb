require 'physical_level'
require 'walls'

class PlaygroundLevel < PhysicalLevel
  def setup
    i = @input_manager
    @shooter = create_actor :box_shooter, :x => 30, :y => 700

    @last_mouse_x = 200
    @last_mouse_y = 200

    create_actor(:left_wall)
    create_actor(:right_wall)
    create_actor(:top_wall)
    create_actor(:bottom_wall)

    space.gravity = vec2(0, 300)

    i.reg KeyPressed, :space do
      create_actor :clicky, :x => @last_mouse_x, :y => @last_mouse_y
    end

    i.reg MouseMotionEvent do |evt|
      @velocity = vec2((evt.pos[0] - @last_mouse_x) * 1.2, (evt.pos[1] - @last_mouse_y) * 1.2)
      @last_mouse_x = evt.pos[0]
      @last_mouse_y = evt.pos[1]
    end

    i.reg MouseDownEvent do |evt|
      pick(evt.pos[0], evt.pos[1]) do |actor|
        puts "Got actor #{actor}"
        @grabbed = actor
      end

      if @grabbed
        # add Pin constraint
        # TODO should this move to Actor#pin or something?

        @offset_x = evt.pos[0] - @grabbed.x
        @offset_y = evt.pos[1] - @grabbed.y
        
        @mouse_body = Body.new Float::INFINITY, Float::INFINITY
        @pin = Constraint::PivotJoint.new(@mouse_body, @grabbed.body, vec2(0,0), vec2(@offset_x,-@offset_y))
        register_physical_constraint @pin
      end
    end

    i.reg MouseUpEvent do |evt|
      @grabbed = nil
      unregister_physical_constraint @pin if @pin
    end

    space.elastic_iterations = 3
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
  end

  def update(delta)
    if @grabbed
#      @grabbed.warp vec2(@last_mouse_x - @offset_x, @last_mouse_y - @offset_y)
#      @grabbed.body.v = @velocity * delta
      @mouse_body.p = vec2(@last_mouse_x - @offset_x, @last_mouse_y - @offset_y)
      @mouse_body.v = @velocity * delta
    end

    super
  end
end

