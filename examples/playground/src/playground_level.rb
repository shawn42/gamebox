require 'physical_level'
require 'walls'

class PlaygroundLevel < PhysicalLevel
  def setup
    i = @input_manager
    @shooter = create_actor :box_shooter, :x => 30, :y => 700

    create_actor(:left_wall)
    create_actor(:right_wall)
    create_actor(:top_wall)
    create_actor(:bottom_wall)

    space.gravity = vec2(0, 300)

    i.reg KeyPressed, :space do
      create_actor :clicky, :x => @mouse_x, :y => @mouse_y
    end

    i.reg MouseMotionEvent do |evt|
      @mouse_x = evt.pos[0]
      @mouse_y = evt.pos[1]
    end

    i.reg MouseDownEvent do |evt|
      pick(evt.pos[0], evt.pos[1]) do |actor|
        puts "Got actor #{actor}"
      end
    end

    space.elastic_iterations = 3
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
  end
end

