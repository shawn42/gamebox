# available shape_types are :circle, :polygon, :aabb
Behavior.define :collidable do

  requires_behaviors :positioned

  requires :stage
  setup do
    shape_type = opts[:shape]

    w = actor.do_or_do_not(:width) || 1
    h = actor.do_or_do_not(:height) || 1
    hw = w / 2
    hh = h / 2
    x = (actor.do_or_do_not(:x) || 0) - hw
    y = (actor.do_or_do_not(:y) || 0) - hh

    actor.has_attributes( shape_type: shape_type,
                          x: x,
                          y: y,
                          width: w,
                          height: h
                        )

    shape_klass = shape_type.to_s.capitalize + "Collidable"
    shape = Object.const_get(shape_klass).new actor, opts
    shape.setup

    bb = Rect.new
    bb.x = actor.x
    bb.y = actor.y
    bb.w = actor.width
    bb.h = actor.height


    actor.has_attributes( shape: shape,
                          center_x: shape.center_x,
                          center_y: shape.center_y,
                          cw_world_points: shape.cw_world_points,
                          cw_world_lines: shape.cw_world_lines,
                          cw_world_edge_normals: shape.cw_world_edge_normals,
                          bb: bb,
                          radius: shape.radius
                        )

    stage.register_collidable actor

    actor.when :remove_me do
      stage.unregister_collidable actor
    end

    actor.when(:position_changed) { position_changed }
  end

  helpers do
    def position_changed
      shape = actor.shape
      shape.recalculate_collidable_cache
      actor.center_x = shape.center_x
      actor.center_y = shape.center_y
      actor.width = shape.width
      actor.height = shape.height
      actor.cw_world_points = shape.cw_world_points
      actor.cw_world_lines = shape.cw_world_lines
      actor.cw_world_edge_normals = shape.cw_world_edge_normals
      actor.radius = shape.radius

      bb = actor.bb
      bb.x = actor.x
      bb.y = actor.y
      bb.w = actor.width
      bb.h = actor.height
    end
  end
end
