define_behavior :positioned do
  setup do
    x = opts[:x] || 0
    y = opts[:y] || 0
    actor.has_attributes x: x, y: y
    actor.has_attributes position: vec2(actor.x, actor.y)
    actor.when(:x_changed) { actor.position = vec2(actor.x, actor.y) }
    actor.when(:y_changed) { actor.position = vec2(actor.x, actor.y) }
  end

end
