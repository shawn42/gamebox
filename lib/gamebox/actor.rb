require 'publisher'
# Actor represent a game object.
# Actors can have behaviors added and removed from them. Such as :physical or :animated.
# They are created and hooked up to their optional View class in Level#create_actor.
class Actor
  extend Publisher
  can_fire_anything
  
  attr_accessor :behaviors, :x, :y, :level, :input_manager,
    :resource_manager, :alive, :opts, :sound_manager, :visible,
    :director


  def initialize(opts={}) # :nodoc:
    @opts = opts
    @x = @opts[:x]
    @y = @opts[:y]
    @x ||= 0
    @y ||= 0
    @level = opts[:level]
    @input_manager = opts[:input]
    @sound_manager = opts[:sound]
    @resource_manager = opts[:resources]
    @director = opts[:director]
    @alive = true

    @behaviors = {}

    # add our classes behaviors and parents behaviors
    klass = self.class
    actor_klasses = []
    while klass != Actor
      actor_klasses << klass
      klass = klass.superclass
    end

    behavior_defs = {}
    
    actor_klasses.each do |actor_klass|
      actor_behaviors = actor_klass.behaviors.dup
      actor_behaviors.each do |behavior|

        behavior_sym = behavior.is_a?(Hash) ? behavior.keys.first : behavior

        behavior_defs[behavior_sym] = behavior
      end
    end

    for behavior in behavior_defs.values
      is behavior
    end
    setup
  end

  # Called at the end of actor/behavior initialization. To be defined by the
  # child class.
  def setup
  end

  # Is the actor still alive?
  def alive?
    @alive
  end

  # Tells the actor's Director that he wants to be removed; and unsubscribes
  # the actor from all input events.
  def remove_self
    @alive = false
    fire :remove_me
    @input_manager.unsubscribe_all self
  end

  # Does this actor have this behavior?
  def is?(behavior_sym)
    !@behaviors[behavior_sym].nil?
  end

  # Adds the given behavior to the actor. Takes a symbol or a Hash.
  #  act.is(:shootable) or act.is(:shootable => {:range=>3})
  #  this will create a new instance of Shootable and pass
  #  :range=>3 to it
  #  Actor#is does try to require 'shootable' but will not throw an error if shootable cannot be required.
  def is(behavior_def)
    behavior_sym = behavior_def.is_a?(Hash) ? behavior_def.keys.first : behavior_def
    behavior_opts = behavior_def.is_a?(Hash) ? behavior_def.values.first : {}
    begin
      require behavior_sym.to_s;
    rescue LoadError
      # maybe its included somewhere else
    end
    klass = Object.const_get Inflector.camelize(behavior_sym)
    @behaviors[behavior_sym] = klass.new self, behavior_opts
  end

  # removed the behavior from the actor.
  def is_no_longer(behavior_sym)
    behavior = @behaviors.delete behavior_sym
    behavior.removed if behavior
  end

  # Calls update on all the actor's behaviors.
  def update_behaviors(time)
    for behavior in @behaviors.values
      behavior.update time
    end
  end

  # Creates a new actor and returns it. (This actor will automatically be added to the Director.
  def spawn(type, args={})
    @level.create_actor type, args
  end

  # Plays a sound via the SoundManager.  See SoundManager for
  # details on how to "define" sounds.
  def play_sound(*args)
    @sound_manager.play_sound *args
  end

  # Stops a sound via the SoundManager.
  def stop_sound(*args)
    @sound_manager.stop_sound *args
  end

  # to be defined in child class
  def update(time)
    # TODO maybe use a callback list for child classes
    update_behaviors time
  end
  
  def hide
    fire :hide_me if visible?
    @visible = false
  end
  
  def show
    fire :show_me unless visible?
    @visible = true
  end
  
  def visible?
    @visible
  end
  
  # magic
  metaclass.instance_eval do
    define_method( :behaviors ) do
      @behaviors ||= []
    end
    define_method( :has_behaviors ) do |*args|
      @behaviors ||= []
      for a in args
        if a.is_a? Hash
          for k,v in a 
            h = {}
            h[k]=v
            @behaviors << h
          end
        else
          @behaviors << a
        end
      end
      @behaviors
    end
    define_method( :has_behavior ) do |*args|
      has_behaviors *args
    end
  end
end
