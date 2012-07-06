# Directors manage actors.
class Director
  attr_accessor :actors, :update_slots

  def initialize
    @update_slots = [ :pre_update, :update, :post_update ]
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

  def when(event=:update, &callback)
    @subscriptions[event] ||= []
    @subscriptions[event] << callback
  end

  def update(time)
    time_in_seconds = time / 1000.to_f
    @update_slots.each do |slot|
      @subscriptions[slot].each do |callback|
        callback.call time, time_in_seconds
      end
    end
  end


  private
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
