define_behavior :positioned do
  setup do
    x = opts[:x] || actor.do_or_do_not(:x) || 0
    y = opts[:y] || actor.do_or_do_not(:y) || 0
    actor.has_attributes position: vec2(x, y), x: x, y: y
    actor.when(:x_changed) { actor.position = vec2(actor.x, actor.y) }
    actor.when(:y_changed) { actor.position = vec2(actor.x, actor.y) }

    actor.when(:position_changed) do
      actor.update_attributes(
        x: actor.position.x,
        y: actor.position.y
      )
    end
  end

end
