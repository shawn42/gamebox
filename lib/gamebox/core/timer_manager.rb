class TimerManager

  def initialize
    @timers ||= {}
    @dead_timers = []
    @callbacks = []
  end

  # add block to be executed every interval_ms millis
  def add_timer(name, interval_ms, recurring = true, &block)
    raise "timer [#{name}] already exists" if @timers[name]
    @timers[name] = {
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
    @callbacks.clear
    @dead_timers.clear

    @timers.each do |name, timer_hash|
      timer_hash[:count] += time_delta
      if timer_hash[:count] > timer_hash[:interval_ms]
        timer_hash[:count] -= timer_hash[:interval_ms]
        @callbacks << timer_hash[:callback]
        @dead_timers << name unless timer_hash[:recurring]
      end
    end
    @dead_timers.each do |name|
      remove_timer name
    end
    @callbacks.each &:call
  end

  def pause
    @paused_timers = @timers
    @timers = {}
  end

  def unpause
    @timers = @paused_timers
    @paused_timers = {}
  end

end
