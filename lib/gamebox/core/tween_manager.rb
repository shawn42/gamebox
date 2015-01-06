class TweenManager
  construct_with :director

  def initialize
    @tweens = []
    director.when :update, &method(:update)
  end

  def tween_properties(actor, properties, time, tween_style=Tween::Linear)
    tween = TweenWrapper.new(actor, properties, time, tween_style)
    @tweens << tween
    # return it so we can cancel it
    tween
  end

  def update(time, time_in_secs)
    @tweens.each do |tween|
      tween.update time unless tween.done?
    end
    @tweens.reject! &:done?
  end

end
