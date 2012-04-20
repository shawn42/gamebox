Behavior.define :positioned do
  requires :director
  setup do
    x = actor.opts[:x] || 0
    y = actor.opts[:y] || 0
    actor.has_attributes x: x, y: y
    director.when :update do |time|
      actor.react_to :position_changed if @x_dirty || @y_dirty
      @x_dirty = false
      @y_dirty = false
    end
    actor.when :x_changed do @x_dirty = true end
    actor.when :y_changed do @y_dirty = true end
  end
end
