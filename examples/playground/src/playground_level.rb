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

#    space.add_collision_func(:box, [:left_wall, :right_wall, :top_wall, :bottom_wall]) do |box, wall|
#      puts "Box #{box.inspect} ran into wall #{wall.inspect}"
#    end

    space.elastic_iterations = 10
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
  end
end

