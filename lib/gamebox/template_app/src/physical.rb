require 'behavior'
class Physical < Behavior
  attr_accessor :shape, :body

  # how can/should an Actor declare these things in their class?
  #  - mass
  #  - shape
  #    - shape specific geometry
  #    - e 
  #    - u
  def setup
    @mass = 50

    # CIRCLE
    @radius = 10
    moment_of_inertia = moment_for_circle(@mass, @radius,0, ZeroVec2)
    @body = Body.new(@mass, moment_of_inertia)
    @shape = Shape::Circle.new(@body, @radius, ZeroVec2)

    # POLY
#    shape_array = [vec2(-25.0, -25.0), vec2(-25.0, 25.0), vec2(25.0, 1.0), vec2(25.0, -1.0)]
#    shape = Shape::Poly.new(body, shape_array, ZeroVec2)


    @shape.collision_type = @actor.class.to_s.downcase.to_sym
    @shape.body.p = ZeroVec2
    @shape.e = 0.1
    @shape.u = 0.7

    physical_obj = self

    if @actor.level.respond_to? :register_physical_object
      @actor.level.register_physical_object physical_obj
    else
      raise "physical actor in a non-physical level!"
    end
    # write code here to keep physics and x,y of actor in sync
    @actor.class.class_eval do
      define_method :x do 
        physical_obj.body.p.x
      end
    end
    @actor.class.class_eval do
      define_method :y do 
        physical_obj.body.p.y
      end
    end
    @actor.class.class_eval do
      define_method :x= do |new_x|
        raise "I am physical, you should apply forces"
      end
    end
    @actor.class.class_eval do
      define_method :y= do |new_y|
        raise "I am physical, you should apply forces"
      end
    end
  end
end
