require 'publisher'
# Actor represent a game object.
# Actors can have behaviors added and removed from them. Such as :physical or :animated.
# They are created and hooked up to their optional View class in Level#create_actor.
class Actor
  extend Publisher

  attr_accessor :behaviors, :x, :y, :level, :input_manager,
    :resource_manager, :alive, :opts

  can_fire_anything

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
    @alive = true

    @behaviors = {}
    # add our classes behaviors
    class_behaviors = self.class.behaviors.dup
    for behavior in class_behaviors
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
    @behaviors.delete behavior_sym
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

  # to be defined in child class
  def update(time)
    # TODO maybe use a callback list for child classes
    update_behaviors time
  end

  # to be defined in child class
  def draw(target)
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
  end
end
