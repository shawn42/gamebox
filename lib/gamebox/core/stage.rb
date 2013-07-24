# Stage is a state that the game is in.  (ie intro stage, multiplayer stage,
# single player stage).
class Stage
  include Arbiter
  extend Publisher
  can_fire_anything

  construct_with :input_manager, :actor_factory, :resource_manager, 
    :sound_manager, :config_manager, :director, :timer_manager, 
    :viewport, :this_object_context

  attr_accessor :opts, :backstage

  def configure(backstage, opts)
    viewport.reset

    @backstage = backstage
    @opts = opts
    renderer.clear_drawables
  end

  def create_actor(type, args={})
    actor_factory.build type, args
  end
  alias :spawn :create_actor 

  def draw(target)
    renderer.draw target
  end

  def update(time)
    director.update time
    viewport.update time
    find_collisions
    timer_manager.update time
  end

  def curtain_up(*args)
  end

  def curtain_down(*args)
  end

  def on_pause(&block)
    @pause_listeners ||= []
    @pause_listeners << block if block_given?
  end

  def on_unpause(&block)
    @unpause_listeners ||= []
    @unpause_listeners << block if block_given?
  end

  def paused?
    @pause
  end

  def pause
    @pause_listeners ||= []
    @paused = true
    director.pause
    timer_manager.pause
    input_manager.pause
    @pause_listeners.each do |listener|
      listener.call
    end
  end

  def unpause
    @unpause_listeners ||= []
    director.unpause
    input_manager.unpause
    timer_manager.unpause
    @unpause_listeners.each do |listener|
      listener.call
    end
    @paused = true
  end

  # pauses the current stage, creates an actor using args, unpauses on actor death
  #
  # Example:
  #  modal_actor :dialog, x: 40, y: 50, message: "WOW"
  def modal_actor(*args)
    on_pause do
      pause_actor = create_actor *args
      pause_actor.when :remove_me do
        @pause_listeners = nil
        unpause
        yield if block_given?
      end
    end
    pause

  end

  private

  class << self

    def define(stage_name, opts={}, &blk)
      @definitions ||= {}
      raise "Stage [#{stage_name}] already defined at #{@definitions[stage_name].source}" if @definitions[stage_name]

      definition = StageDefinition.new
      definition.source = caller.detect{|c|!c.match /core/}
      definition.instance_eval &blk if block_given?
      @definitions[stage_name] = definition
    end

    def definitions
      @definitions ||= {}
    end
  end

end

