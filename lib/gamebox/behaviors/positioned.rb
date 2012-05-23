define_behavior :positioned do
  requires :director
  setup do
    x = opts[:x] || 0
    y = opts[:y] || 0
    actor.has_attributes x: x, y: y
    director.when :update do |time|
      if @x_dirty || @y_dirty
        actor.react_to :position_changed
        actor.emit :position_changed 
      end
      @x_dirty = false
      @y_dirty = false
    end
    actor.when :x_changed do @x_dirty = true end
    actor.when :y_changed do @y_dirty = true end
  end
end
