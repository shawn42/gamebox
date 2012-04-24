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
Behavior.define :physical do
  
  requires :physics_manager
  setup do
    @moment_of_inertia = @opts[:moment]

    actor.has_attributes :x, :y, :shape, :shapes, :body,
      :rotation, :warp, :segment_groups, :physical,
      :pivot, :pin, :spring, :slide, :groove,
      :rotary_spring, :rotary_limit, :ratchet,
      :gear, :motor

    actor.shapes = []
    actor.constraints = []
    actor.segment_groups = []


    build_main_shape
    setup_main_collisions
    setup_position
    setup_elasticity
    setup_friction

    build_secondary_shapes

    register

    # TODO use positioned?
    actor.when :x_changed do
      actor.body.p = vec2(actor.x, actor.y)
    end
    actor.when :y_changed do 
      actor.body.p = vec2(actor.x, actor.y)
    end

    director.when :update do |time|
      actor.x = actor.body.p.x
      actor.y = actor.body.p.y
      actor.roation = rotation
    end

    warp(vec2(actor.x,actor.y))
  end

  helpers do
    def setup_friction
      @friction = @opts[:friction]
      @friction ||= 0.4
      actor.shape.u = @friction
    end

    def setup_elasticity
      @elasticity = @opts[:elasticity]
      @elasticity ||= 0.1
      actor.shape.e = @elasticity
    end

    def setup_main_collisions
      @collision_type = @opts[:collision_group]
      @collision_type ||= actor.actor_type
      actor.shape.collision_type = @collision_type
    end

    def setup_position
      actor.body.a = @opts[:angle] if @opts[:angle]
      start_x = @opts[:x]
      start_y = @opts[:y]
      start_x ||= actor.x
      start_y ||= actor.y
      actor.shape.body.p = vec2(start_x,start_y)

    end

    def build_main_shape
      @mass = @opts[:mass]
      @mass ||= Float::INFINITY

      case @opts[:shape]
      when :circle
        @radius = @opts[:radius]

        @moment_of_inertia ||= @opts[:fixed] ? Float::INFINITY : CP::moment_for_circle(@mass, @radius, 0, ZERO_VEC_2)
        actor.body = CP::Body.new(@mass, @moment_of_inertia)
        actor.shape = CP::Shape::Circle.new(actor.body, @radius, ZERO_VEC_2)

      when :poly
        shape_array = @opts[:verts].collect{|v| vec2(v[0],v[1])}

        @moment_of_inertia ||= @opts[:fixed] ? Float::INFINITY : CP::moment_for_poly(@mass, shape_array, ZERO_VEC_2)
        actor.body = CP::Body.new(@mass, @moment_of_inertia)
        actor.shape = CP::Shape::Poly.new(actor.body, shape_array, ZERO_VEC_2)
        verts = @opts[:verts].dup
        verts << @opts[:verts][0]
        actor.segment_groups << verts
      end

      actor.shapes << actor.shape

      actor.body.p = vec2(actor.x,actor.y)
    end

    def build_secondary_shapes

      if @opts[:shapes]
        for obj in @opts[:shapes]
          for part_name, part_def in obj
            # TODO merge this with build main shape
            part_shape = nil
            case part_def[:shape]
            when :poly
              part_shape_array = part_def[:verts].collect{|v| vec2(v[0],v[1])}
              part_shape = CP::Shape::Poly.new(actor.body, part_shape_array, part_def[:offset])
              part_shape.collision_type = part_name.to_sym

              # TODO pass all physics params to parts (ie u and e)
              part_shape.u = @friction
              verts = part_def[:verts].dup
              verts << part_def[:verts][0]
              actor.segment_groups << verts
            when :circle
              part_shape = CP::Shape::Circle.new(actor.body, part_def[:radius], part_def[:offset])
            else
              raise "unsupported sub shape type"
            end
            part_shape.collision_type = part_name.to_sym
            actor.shapes << part_shape
          end
        end
      end
    end

    def register
      actor.when :remove_me do
        cleanup_constraints
      end

      if physics_manager
        if @opts[:fixed]
          physics_manager.register_physical_object actor, true
        else
          physics_manager.register_physical_object actor
        end
      else
        raise "physical actor in a non-physical stage!"
      end
    end



    def rotation
      if opts[:shape] == :poly
        ((actor.body.a-1.57) * 180.0 / Math::PI + 90) % 360
      else
        ((actor.body.a) * 180.0 / Math::PI + 90) % 360
      end
    end

    def warp(new_p)
      actor.body.p = new_p
      physics_manager.space.rehash_static if opts[:fixed]
    end

    # TODO use react_to to handle these requests?
    # def pivot(my_anchor, other_physical, other_anchor)
    #   pivot = CP::Constraint::PivotJoint.new(actor.body, other_physical.actor.body, my_anchor, other_anchor)
    #   physics_manager.register_physical_constraint pivot
    #   actor.constraints << pivot
    #   pivot
    # end

    # def pin(my_anchor, other_physical, other_anchor)
    #   pin = CP::Constraint::PinJoint.new(actor.body, other_physical.physical.body, my_anchor, other_anchor)
    #   physics_manager.register_physical_constraint pin
    #   actor.constraints << pin
    #   pin
    # end

    # def spring(my_anchor, other_physical, other_anchor, rest_length, stiffness, damping)
    #   spring = CP::Constraint::DampedSpring.new(body,other_physical.body,
    #                                        my_anchor,other_anchor, rest_length, stiffness, damping)
    #   physics_manager.register_physical_constraint spring
    #   actor.constraints << spring
    #   spring
    # end

    # def slide(my_anchor, other_physical, other_anchor, min_distance, max_distance)
    #   slide = CP::Constraint::SlideJoint.new(actor.body, other_physical.body, my_anchor, other_anchor, min_distance, max_distance)
    #   physics_manager.register_physical_constraint slide
    #   actor.constraints << slide
    #   slide
    # end

    # def groove(groove_start, groove_end, other_physical, other_anchor)
    #   groove = CP::Constraint::GrooveJoint.new(actor.body, other_physical.body, groove_start, groove_end, other_anchor)
    #   physics_manager.register_physical_constraint groove
    #   actor.constraints << groove
    #   groove
    # end

    # #
    # # All of these rotary joint types expect angles in radians.
    # #

    # def rotary_spring(other_physical, rest_angle, stiffness, damping)
    #   rotary_spring = CP::Constraint::DampedRotarySpring.new(actor.body, other_physical.body, rest_angle, stiffness, damping)
    #   physics_manager.register_physical_constraint rotary_spring
    #   actor.constraints << rotary_spring
    #   rotary_spring
    # end

    # def rotary_limit(other_physical, min_angle, max_angle)
    #   rotary_limit = CP::Constraint::RotaryLimitJoint.new(actor.body, other_physical.body, min_angle, max_angle)
    #   physics_manager.register_physical_constraint rotary_limit
    #   actor.constraints << rotary_limit
    #   rotary_limit
    # end

    # def ratchet(other_physical, phase, ratchet)
    #   ratchet_joint = CP::Constraint::RatchetJoint.new(actor.body, other_physical.body, phase, ratchet)
    #   physics_manager.register_physical_constraint ratchet_joint
    #   actor.constraints << ratchet_joint
    #   ratchet_joint
    # end

    # def gear(other_physical, phase, ratio)
    #   gear = CP::Constraint::GearJoint.new(actor.body, other_physical.body, phase, ratio)
    #   physics_manager.register_physical_constraint gear
    #   actor.constraints << gear
    #   gear
    # end

    # def motor(other_physical, rate)
    #   motor = CP::Constraint::SimpleMotor.new(actor.body, other_physical.body, rate)
    #   physics_manager.register_physical_constraint motor
    #   actor.constraints << motor
    #   motor
    # end

    def cleanup_constraints
      actor.constraints.each do |c|
        physics_manager.unregister_physical_constraint c
      end
    end
  end

end
