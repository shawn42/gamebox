
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
    if @shapes
      @shapes.first 
    else
      @shape
    end
  end
  
  def setup
    @parts = {}
    @shapes = []
    @constraints = []
    @segments_groups = []

    @moment_of_inertia = @opts[:moment]

    build_main_shape
    setup_main_collisions
    setup_position
    setup_elasticity
    setup_friction

    build_secondary_shapes

    register

    # write code here to keep physics and x,y of actor in sync
    relegates :x, :y, :x=, :y=, :shape, :body, :parts,
      :rotation, :warp, :segment_groups, :physical,
      :pivot, :pin, :spring, :slide, :groove,
      :rotary_spring, :rotary_limit, :ratchet,
      :gear, :motor
  end

  def setup_friction
    @friction = @opts[:friction]
    @friction ||= 0.4
    @shape.u = @friction
  end

  def setup_elasticity
    @elasticity = @opts[:elasticity]
    @elasticity ||= 0.1
    @shape.e = @elasticity
  end

  def setup_main_collisions
    @collision_type = @opts[:collision_group]
    @collision_type ||= 
      Inflector.underscore(@actor.class).to_sym
    @shape.collision_type = @collision_type
  end

  def setup_position
    @body.a = @opts[:angle] if @opts[:angle]
    start_x = @opts[:x]
    start_y = @opts[:y]
    start_x ||= @actor.x
    start_y ||= @actor.y
    @shape.body.p = vec2(start_x,start_y)

  end

  def build_main_shape
    @mass = @opts[:mass]
    @mass ||= Float::INFINITY

    case @opts[:shape]
    when :circle
      @radius = @opts[:radius]

      @moment_of_inertia ||= @opts[:fixed] ? Float::INFINITY : moment_for_circle(@mass, @radius, 0, ZERO_VEC_2)
      @body = CP::Body.new(@mass, @moment_of_inertia)
      @shape = CP::Shape::Circle.new(@body, @radius, ZERO_VEC_2)

    when :poly
      shape_array = @opts[:verts].collect{|v| vec2(v[0],v[1])}

      @moment_of_inertia ||= @opts[:fixed] ? Float::INFINITY : moment_for_poly(@mass, shape_array, ZERO_VEC_2)
      @body = CP::Body.new(@mass, @moment_of_inertia)
      @shape = CP::Shape::Poly.new(@body, shape_array, ZERO_VEC_2)
      verts = @opts[:verts].dup
      verts << @opts[:verts][0]
      @segments_groups << verts
    end

    @shapes << @shape
  end

  def build_secondary_shapes

    if @opts[:shapes]
      for obj in @opts[:shapes]
        for part_name, part_def in obj
          # add another shape here
          part_shape_array = part_def[:verts].collect{|v| vec2(v[0],v[1])}
          part_shape = CP::Shape::Poly.new(@body, part_shape_array, part_def[:offset])
          part_shape.collision_type = part_name.to_sym
          # TODO pass all physics params to parts (ie u and e)
          part_shape.u = @friction
          @shapes << part_shape
          verts = part_def[:verts].dup
          verts << part_def[:verts][0]
          @segments_groups << verts
        end
      end
    end
  end

  def register
    @actor.when :remove_me do
      cleanup_constraints
    end

    physical_obj = self
    if @actor.stage.respond_to? :register_physical_object
      if @opts[:fixed]
        @actor.stage.register_physical_object physical_obj, true
      else
        @actor.stage.register_physical_object physical_obj
      end
    else
      raise "physical actor in a non-physical stage!"
    end
  end

  def x
    body.p.x
  end

  def y
    body.p.y
  end

  def x=(new_x)
    body.p = vec2(new_x, y)
  end

  def y=(new_y)
    body.p = vec2(x, new_y)
  end

  def rotation
    # TODO hack!! why do poly's not work the same?
    if opts[:shape] == :poly
      ((body.a-1.57) * 180.0 / Math::PI + 90) % 360
    else
      ((body.a) * 180.0 / Math::PI + 90) % 360
    end
  end

  def warp(new_p)
    body.p = new_p
    @actor.stage.space.rehash_static if opts[:fixed]
  end

  def physical
    self
  end

  def pivot(my_anchor, other_physical, other_anchor)
    pivot = CP::Constraint::PivotJoint.new(physical.body, other_physical.physical.body, my_anchor, other_anchor)
    @actor.stage.register_physical_constraint pivot
    @constraints << pivot
    pivot
  end

  def pin(my_anchor, other_physical, other_anchor)
    pin = CP::Constraint::PinJoint.new(physical.body, other_physical.physical.body, my_anchor, other_anchor)
    @actor.stage.register_physical_constraint pin
    @constraints << pin
    pin
  end

  def spring(my_anchor, other_physical, other_anchor, rest_length, stiffness, damping)
    spring = CP::Constraint::DampedSpring.new(physical.body,other_physical.physical.body,
                                         my_anchor,other_anchor, rest_length, stiffness, damping)
    @actor.stage.register_physical_constraint spring
    @constraints << spring
    spring
  end

  def slide(my_anchor, other_physical, other_anchor, min_distance, max_distance)
    slide = CP::Constraint::SlideJoint.new(physical.body, other_physical, my_anchor, other_anchor, min_distance, max_distance)
    @actor.stage.register_physical_constraint slide
    @constraints << slide
    slide
  end

  def groove(groove_start, groove_end, other_physical, other_anchor)
    groove = CP::Constraint::GrooveJoint.new(physical.body, other_physical, groove_start, groove_end, other_anchor)
    @actor.stage.register_physical_constraint groove
    @constraints << groove
    groove
  end

  #
  # All of these rotary joint types expect angles in radians.
  #

  def rotary_spring(other_physical, rest_angle, stiffness, damping)
    rotary_spring = CP::Constraint::DampedRotarySpring.new(physical.body, other_physical, rest_angle, stiffness, damping)
    @actor.stage.register_physical_constraint rotary_spring
    @constraints << rotary_spring
    rotary_spring
  end

  def rotary_limit(other_physical, min_angle, max_angle)
    rotary_limit = CP::Constraint::RotaryLimitJoint.new(physical.body, other_physical, min_angle, max_angle)
    @actor.stage.register_physical_constraint rotary_limit
    @constraints << rotary_limit
    rotary_limit
  end

  def ratchet(other_physical, phase, ratchet)
    ratchet_joint = CP::Constraint::RatchetJoint.new(physical.body, other_physical, phase, ratchet)
    @actor.stage.register_physical_constraint ratchet_joint
    @constraints << ratchet_joint
    ratchet_joint
  end

  def gear(other_physical, phase, ratio)
    gear = CP::Constraint::GearJoint.new(physical.body, other_physical, phase, ratio)
    @actor.stage.register_physical_constraint gear
    @constraints << gear
    gear
  end

  def motor(other_physical, rate)
    motor = CP::Constraint::SimpleMotor.new(physical.body, other_physical, rate)
    @actor.stage.register_physical_constraint motor
    @constraints << motor
    motor
  end

  def cleanup_constraints
    @constraints.each do |c|
      @actor.stage.unregister_physical_constraint c
    end
  end

end
