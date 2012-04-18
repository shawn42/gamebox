# available shape_types are :circle, :polygon, :aabb
Behavior.define :collidable do

  requires :stage, :director
  setup do
    shape_type = opts[:shape]

    w = actor.do_or_do_not(:width) || 1
    h = actor.do_or_do_not(:height) || 1
    hw = w / 2
    hh = h / 2
    x = (actor.do_or_do_not(:x) || 0) - hw
    y = (actor.do_or_do_not(:y) || 0) - hh
    bb ||= Rect.new
    bb.x = x
    bb.y = y
    bb.w = w
    bb.h = h

    actor.has_attributes( shape_type: shape_type,
                          width: w,
                          height: h,
                          x: x,
                          y: y,
                          bb: bb )

    shape = 
      case shape_type
      when :circle
        CircleCollidable.new actor, opts
      when :aabb
        AaBbCollidable.new actor, opts
      when :polygon
        PolygonCollidable.new actor, opts
      end
    shape.setup

    actor.has_attributes( shape: shape,
                          center_x: shape.center_x,
                          center_y: shape.center_y,
                          cw_world_points: shape.cw_world_points,
                          cw_world_lines: shape.cw_world_lines,
                          cw_world_edge_normals: shape.cw_world_edge_normals,
                          radius: shape.radius
                        )

    # TODO watch for x, y, w, h changes instead?
    director.when :update do |time|
      shape.update(time)
      actor.center_x = shape.center_x
      actor.center_y = shape.center_y
      actor.cw_world_points = shape.cw_world_points
      actor.cw_world_lines = shape.cw_world_lines
      actor.cw_world_edge_normals = shape.cw_world_edge_normals
      actor.radius = shape.radius
    end

    stage.register_collidable actor
  end

  react_to do |message, *args|
    case message
    when :remove
      stage.unregister_collidable actor
    end
  end

  # TODO was this needed?
  # def method_missing(name, *args)
  #   @shape.send(name, *args)
  # end
end
