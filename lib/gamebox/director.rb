# Directors manage actors.
class Director
  extend Publisher
  can_fire_anything
  attr_accessor :actors

  def initialize
    @actors = []
    @dead_actors = []
    setup
  end

  def setup
  end

  def add_actor(actor)
    @actors << actor
    actor.when :remove_me do
      remove_actor actor
    end
    fire :actor_added, actor
    actor
  end

  def remove_actor(actor)
    @dead_actors << actor
  end

  def empty?
    @actors.empty?
  end

  def pause
    @paused_actors = @actors
    @actors = []
  end

  def unpause
    unless @paused_actors.nil?
      @actors.each{|actor| actor.remove_self }
      @actors = @paused_actors
      @paused_actors = nil
    end
  end

  def update(time)
    for act in @dead_actors
      @actors.delete act
      fire :actor_removed, act
    end
    @dead_actors = []
    fire :update, time
    # for act in @actors
    #   act.update time if act.alive?
    # end
  end
end
