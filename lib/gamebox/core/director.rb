# Directors manage actors.
class Director
  extend Publisher
  can_fire_anything
  attr_accessor :actors

  def pause
    @paused_subscriptions = @subscriptions
    @subscriptions = {}
  end

  def unpause
    unless @paused_subscriptions.nil?
      @subscriptions = @paused_subscriptions
      @paused_subscriptions = nil
    end
  end

  def update(time)
    time_in_seconds = time / 1000.to_f
    fire :update, time, time_in_seconds
  end
end
