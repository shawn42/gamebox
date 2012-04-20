class TimerManager

  def initialize
    @timers ||= {}
    @new_timers = {}
    @dead_timers = []
  end

  # add block to be executed every interval_ms millis
  # TODO make this hash based on object => name => block
  # to clean up the timed behavior
  def add_timer(name, interval_ms, recurring = true, &block)
    @new_timers = {}
    @new_timers[name] = {
      count: 0, recurring: recurring,
      interval_ms: interval_ms, callback: block}
  end

  def remove_timer(name)
    @timers.delete name
  end

  def timer(name)
    @timers[name]
  end

  # update each timers counts, call any blocks that are over their interval
  def update(time_delta)
    @dead_timers.each do |name|
      remove_timer name
    end
    # TODO handle overwriting the same timer name...
    if @new_timers
      @timers.merge!(@new_timers) 
      @new_timers.clear!
    end
    @timers.each do |name, timer_hash|
      timer_hash[:count] += time_delta
      if timer_hash[:count] > timer_hash[:interval_ms]
        timer_hash[:count] -= timer_hash[:interval_ms]
        timer_hash[:callback].call
        @dead_timers << name unless timer_hash[:recurring]
      end
    end
  end

  def pause
    @paused_timers = @timers
    @timers = nil
  end

  def unpause
    @timers = @paused_timers
    @paused_timers = nil
  end

end
