require 'behavior'
class Physical < Behavior
  attr_accessor :shape, :body

  def setup
    # TODO add defaults?

    @mass = @opts[:mass]

    case @opts[:shape]
    when :circle
      @radius = @opts[:radius]
      moment_of_inertia = moment_for_circle(@mass, @radius, 0, ZeroVec2)
      @body = Body.new(@mass, moment_of_inertia)
      @shape = Shape::Circle.new(@body, @radius, ZeroVec2)

    when :poly
      shape_array = @opts[:verts].collect{|v| vec2(v[0],v[1])}
      moment_of_inertia = moment_for_poly(@mass, shape_array, ZeroVec2)
      @body = Body.new(@mass, moment_of_inertia)
      @shape = Shape::Poly.new(@body, shape_array, ZeroVec2)
    end

    @shape.collision_type = @actor.class.to_s.downcase.to_sym
    @shape.body.p = ZeroVec2
    @shape.e = 0.1
    @shape.u = 0.7

    physical_obj = self

    # TODO do we want some way of placing the object _BEFORE_
    # dropping it into the physical space?

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
    @actor.class.class_eval do
      define_method :shape do 
        physical_obj.shape
      end
    end
  end
end
