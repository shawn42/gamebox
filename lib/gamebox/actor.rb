# Actor represent a game object.
# Actors can have behaviors added and removed from them. Such as :physical or :animated.
# They are created and hooked up to their optional View class in Stage#create_actor.
class Actor
  extend Publisher
  include EventedAttributes
end
class Actor
  include Gamebox::Extensions::Object::Yoda
  can_fire_anything
  construct_with :this_object_context
  public :this_object_context

  # TODO show/hide methods? go in a behavior? base behavior ActorBehavior?
  has_attribute :alive
  attr_accessor :actor_type

  def initialize
    @behaviors = []
  end

  def configure(opts={}) # :nodoc:
    @opts = opts
    @actor_type = @opts[:actor_type]
    self.alive = true
  end

  def add_behavior(name, behavior)
    # TODO do we need a name here?
    @behaviors << behavior
  end

  def react_to(message, *opts)
    @behaviors.each do |behavior|
      behavior.react_to(message)
    end
  end

  # Tells the actor's Director that he wants to be removed; and unsubscribes
  # the actor from all input events.
  def remove
    self.alive = false
    fire :remove_me
  end

  def to_s
    "#{self.class.name}:#{self.object_id} with behaviors\n#{@behaviors.map(&:class).inspect}"
  end

  # TODO should this live somewhere else?
  # TODO should we support "inheritance" of components?
  class << self

    def define(actor_type)
      @definitions ||= {}
      definition = ActorDefinition.new
      yield definition if block_given?
      @definitions[actor_type] = definition
    end

    def definitions
      @definitions ||= {}
    end

  end

  class ActorDefinition
    attr_accessor :behaviors
    def initialize
      @behaviors = []
    end

    def has_behaviors(*behaviors)
      behaviors.each do |beh|
        @behaviors << beh
      end
    end
    alias has_behavior has_behaviors
  end

end



__END__

  # TODO GUT THIS
  attr_accessor :behaviors, :opts, :visible, :actor_type
  kvo_attr_accessor :x, :y, :alive, :visible
  can_fire_anything

  DEFAULT_PARAMS = {
    :x => 0,
    :y => 0,
  }.freeze

  def initialize
    @behaviors = {}
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
    if behavior_def.is_a?(Hash)
      behavior_sym = behavior_def.keys.first
      behavior_opts = behavior_def.values.first
    else
      behavior_sym = behavior_def
      behavior_opts = {}
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
    stage.spawn type, args
  end

  # to be defined in child class
  def update(time)
    # TODO maybe use a callback list for child classes
    update_behaviors time
  end

  def hide
    fire :hide_me if visible?
    self.visible = false
  end

  def show
    fire :show_me unless visible?
    self.visible = true
  end

  def visible?
    self.visible
  end

  def viewport
    stage.viewport
  end

end
