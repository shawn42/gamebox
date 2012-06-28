# Directors manage actors.
class Director
  attr_accessor :actors, :update_slots

  def initialize
    @update_slots = [ :pre, :update, :post ]
    clear_subscriptions
  end

  def clear_subscriptions
    @subscriptions = Hash[@update_slots.map { |slot| [slot, []] }]
  end

  def pause
    @paused_subscriptions = @subscriptions
    clear_subscriptions
  end

  def unpause
    unless @paused_subscriptions.nil?
      @subscriptions = @paused_subscriptions
      @paused_subscriptions = nil
    end
  end

  def when(event, slot=:update, &callback)
    raise 'director can only fire :update events' unless event == :update
    @subscriptions[slot] << callback
  end

  def update(time)
    time_in_seconds = time / 1000.to_f
    fire :update, time, time_in_seconds
  end

  private
  def fire(event, *args)
    raise 'director can only fire :update events' unless event == :update
    @update_slots.each do |slot|
      @subscriptions[slot].each do |callback|
        callback.call *args
      end
    end
  end

  def unsubscribe_all(listener)
    if @subscriptions
      for slot in @subscriptions.keys
        @subscriptions[slot].delete_if do |block|
          eval('self',block.binding).equal?(listener)
        end
      end
    end
  end

end
