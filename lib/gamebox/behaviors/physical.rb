require 'physics'
require 'behavior'
require 'inflector'
require 'publisher'

# Physical behavior will place your Actor in a physical world.
# example:
# :physical => {
#    :shape => :poly,
#    :parts => [
#      :nario_feet => {:verts => [[-13,20],[-13,21],[13,21],[13,20]],:shape=>:poly, :offset => vec2(0,6)},
#      :nario_hat => {:verts => [[-8,20],[-8,21],[8,21],[8,20]],:shape=>:poly, :offset => vec2(0,-46)}
#      ],
#    :mass => 200,
#    :friction => 0.4,
#    :moment => Float::INFINITY,
#    :verts => [[-15,-20],[-15,20],[15,20],[15,-20]]}
class Physical < Behavior
  attr_accessor :shapes, :body, :opts, :parts, :segments_groups

  def shape
    @shapes.first if @shapes
  end
  
  def setup
    # TODO add defaults?
    @mass = @opts[:mass]
    @mass ||= Float::INFINITY
    @parts = {}
    @shapes = []
    @segments_groups = []

    moment_of_inertia = @opts[:moment]

    case @opts[:shape]
    when :circle
      @radius = @opts[:radius]

      moment_of_inertia ||= @opts[:fixed] ? Float::INFINITY : moment_for_circle(@mass, @radius, 0, ZERO_VEC_2)
      @body = Body.new(@mass, moment_of_inertia)
      @shape = Shape::Circle.new(@body, @radius, ZERO_VEC_2)

    when :poly
      shape_array = @opts[:verts].collect{|v| vec2(v[0],v[1])}

      moment_of_inertia ||= @opts[:fixed] ? Float::INFINITY : moment_for_poly(@mass, shape_array, ZERO_VEC_2)
      @body = Body.new(@mass, moment_of_inertia)
      @shape = Shape::Poly.new(@body, shape_array, ZERO_VEC_2)
      verts = @opts[:verts].dup
      verts << @opts[:verts][0]
      @segments_groups << verts
    end

    collision_type = @opts[:collision_group]
    collision_type ||= 
      Inflector.underscore(@actor.class).to_sym
      
    @body.a = @opts[:angle] if @opts[:angle]

    @shape.collision_type = collision_type
    start_x = @opts[:x]
    start_y = @opts[:y]
    start_x ||= @actor.x
    start_y ||= @actor.y
    @shape.body.p = vec2(start_x,start_y)
    @shape.e = 0.1
    friction = @opts[:friction]
    friction ||= 0.4
    @shape.u = friction
    
    @shapes << @shape

    if @opts[:shapes]
      for obj in @opts[:shapes]
        for part_name, part_def in obj
          # add another shape here
          part_shape_array = part_def[:verts].collect{|v| vec2(v[0],v[1])}
          part_shape = Shape::Poly.new(@body, part_shape_array, part_def[:offset])
          part_shape.collision_type = part_name.to_sym
          # TODO pass all physics params to parts (ie u and e)
          part_shape.u = friction
          @shapes << part_shape
          verts = part_def[:verts].dup
          verts << part_def[:verts][0]
          @segments_groups << verts
        end
      end
    end


    physical_obj = self

    if @actor.level.respond_to? :register_physical_object
      if @opts[:fixed]
        @actor.level.register_physical_object physical_obj, true
      else
        @actor.level.register_physical_object physical_obj
      end
    else
      raise "physical actor in a non-physical level!"
    end

    # write code here to keep physics and x,y of actor in sync
    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :x do 
          physical_obj.body.p.x
        end
        define_method :y do 
          physical_obj.body.p.y
        end
        define_method :x= do |new_x|
          raise "I am physical, you should apply forces"
        end
        define_method :y= do |new_y|
          raise "I am physical, you should apply forces"
        end
        define_method :shape do 
          physical_obj.shape
        end
        define_method :body do 
          physical_obj.body
        end
        define_method :parts do 
          physical_obj.parts
        end
        define_method :deg do 
          # TODO hack!! why do poly's not work the same?
          if physical_obj.opts[:shape] == :poly
            -((physical_obj.body.a-1.57) * 180.0 / Math::PI + 90)
          else
            -((physical_obj.body.a) * 180.0 / Math::PI + 90)
          end
        end
        define_method :warp do |new_p|
          physical_obj.body.p = new_p
          @level.space.rehash_static if physical_obj.opts[:fixed]
        end
        define_method :segment_groups do 
          physical_obj.segments_groups
        end
        define_method :physical do 
          physical_obj
        end
        define_method :image do 
          old_image = nil
          rot_deg = deg.round % 360

          if is? :animated
            old_image = animated.image
          elsif is? :graphical
            old_image = graphical.image
          end

          if old_image
            old_image.rotozoom(rot_deg,1,true)
          end
        end
      end
    end
  end
end
