require 'physics'
require 'behavior'
require 'inflector'
require 'publisher'
class Physical < Behavior
  attr_accessor :shapes, :body, :opts, :parts

  def shape
    @shapes.first if @shapes
  end
  
  def setup
    # TODO add defaults?
    @mass = @opts[:mass]
    @mass ||= Float::Infinity
    @parts = {}
    @shapes = []

    moment_of_inertia = @opts[:moment]

    case @opts[:shape]
    when :circle
      @radius = @opts[:radius]

      moment_of_inertia ||= @opts[:fixed] ? Float::Infinity : moment_for_circle(@mass, @radius, 0, ZeroVec2)
      @body = Body.new(@mass, moment_of_inertia)
      @shape = Shape::Circle.new(@body, @radius, ZeroVec2)

    when :poly
      shape_array = @opts[:verts].collect{|v| vec2(v[0],v[1])}

      moment_of_inertia ||= @opts[:fixed] ? Float::Infinity : moment_for_poly(@mass, shape_array, ZeroVec2)
      @body = Body.new(@mass, moment_of_inertia)
      @shape = Shape::Poly.new(@body, shape_array, ZeroVec2)
    end

    collision_type = @opts[:collision_group]
    collision_type ||= 
      Inflector.underscore(@actor.class).to_sym

    @shape.collision_type = collision_type
    start_x = @opts[:x]
    start_y = @opts[:y]
    start_x ||= @actor.x
    start_y ||= @actor.y
    @shape.body.p = vec2(start_x,start_y)
    @shape.e = 0
    friction = @opts[:friction]
    friction ||= 0.4
    @shape.u = friction
    
    @shapes << @shape

    if @opts[:parts]
      for obj in @opts[:parts]
        for part_name, part_def in obj
          # add another shape here
          part_shape_array = part_def[:verts].collect{|v| vec2(v[0],v[1])}
          part_shape = Shape::Poly.new(@body, part_shape_array, part_def[:offset])
          part_shape.collision_type = part_name.to_sym
          # TODO pass all physics params to parts (ie u and e)
          part_shape.u = friction
          @shapes << part_shape
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

    # if @opts[:parts]
    #   for obj in @opts[:parts]
    #     for part_name, part_def in obj
    #       
          # OLD WAY
#           part_obj = @actor.spawn part_name
#           @parts[part_name] = part_obj
#           a = @body
#           b = part_obj.body
#           if part_def
#             off_x,off_y = *part_def
# 
#             aj = vec2(a.p.x,a.p.y+off_y)
# 
# #            anch_a = a.world2local(aj)
# #            anch_b = b.world2local(-aj)
# 
#             if off_y < 0
#             anch_a = vec2(0,0) #a.world2local(ZeroVec2)
#             anch_b = vec2(0,-off_y) #a.world2local(ZeroVec2)
#             else
#             anch_a = vec2(0,0) #a.world2local(ZeroVec2)
#             anch_b = vec2(0,off_y) #a.world2local(ZeroVec2)
#             end
# #            anch_b = b.world2local(-aj)
# 
#             joint = Constraint::PinJoint.new a, b, anch_a, anch_b
# 
#             # really lock it into place, no floating around
#             joint.bias_coef = 0.99
#             @actor.level.register_physical_constraint joint
# #            part_obj.body.p = vec2(b.p.x+off_x,b.p.y+off_y)
#           end
    #     end
    #   end
    # end

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
          else
            raise "no image could be found"
          end
        end
      end
    end
  end
end
