class TweenWrapper

  def initialize(actor, property_targets, time, style)
    @actor = actor
    @actor.when :remove_me, &method(:cancel!)
    @props = property_targets.keys
    initial_values = @props.map{|pr|actor.send(pr)}
    target_values = @props.map{|pr|property_targets[pr]}
    @tween = Tween.new(initial_values, target_values, style, time)
  end

  def update(time)
    @tween.update time
    @props.each.with_index do |prop, i|
      # maybe use update_attributes instead?
      @actor.send("#{prop}=", @tween[i])
    end
  end

  def cancel!
    @cancel = true
  end

  def done?
    @tween.done || @cancel
  end
end

