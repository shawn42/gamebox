class Timed < Behavior

  def setup
    actor.when :remove_me do |actor|
      clear_timers
    end

    @timers = []
    relegates :add_timer, :remove_timer
  end

  def add_timer(name, ms, recurring = true, &block)
    timer_name = "#{actor.object_id} #{name}"
    @timers << timer_name
    actor.stage.add_timer timer_name, ms do
      block.call
      actor.stage.remove_timer timer_name unless recurring
    end
  end

  def remove_timer(name)
    timer_name = "#{actor.object_id} #{name}"
    @timers.delete timer_name
    actor.stage.remove_timer timer_name
  end

  def clear_timers
    @timers.each do |timer_name|
      actor.stage.remove_timer timer_name
    end
  end

end
