# Actor represent a game object.
# Actors can have behaviors added and removed from them. Such as :physical or :animated.
# They are created and hooked up to their optional View class in Stage#create_actor.
class Actor
  extend Publisher
  include ObservableAttributes
  include Gamebox::Extensions::Object::Yoda
  can_fire_anything
  construct_with :this_object_context
  public :this_object_context

  def initialize
    has_attribute :alive, true
    @behaviors = {}
  end

  def configure(opts={}) # :nodoc:
    has_attributes opts
    self.actor_type = opts[:actor_type]
  end

  # Used by BehaviorFactory#add_behavior.
  # That's probably what you want to use from within another behavior
  def add_behavior(name, behavior)
    @behaviors[name] = behavior
  end
  
  def remove_behavior(name)
    @behaviors.delete(name).tap do |behavior|
      behavior.react_to :remove if behavior
    end
  end

  def react_to(message, *opts)
    # TODO cache the values array?
    @behaviors.values.each do |behavior|
      behavior.react_to(message, *opts)
    end
  end

  def has_behavior?(name)
    @behaviors[name]
  end

  def emit(event, *args)
    fire event, *args
  end

  # Tells the actor's Director that he wants to be removed; and unsubscribes
  # the actor from all input events.
  def remove
    self.alive = false
    react_to :remove
    fire :remove_me
  end

  def to_s
    attrs = []
    attributes.keys.sort.each do |name|
      attrs << "#{name}: #{printable_value(attributes[name])}"
    end
    """
    #{actor_type}:#{self.object_id}
    Behaviors:
    #{@behaviors.keys.sort}
    Attributes:
    #{attrs.join("\n")}
    """
  end
  alias pretty_inspect to_s

  private
  def printable_value(value)
    case value
    when String, Float, Fixnum, TrueClass, FalseClass, Ftor
      value
    when Array
      value.map do |pv|
        printable_value(pv)
      end
    else
      value.class
    end
  end

  # TODO should this live somewhere else?
  class << self

    def define(actor_type, opts={}, &blk)
      @definitions ||= {}
      raise "Actor [#{actor_type}] already defined at #{@definitions[actor_type].source}" if @definitions[actor_type]

      definition = ActorDefinition.new
      # TODO evaluate the perf of doing this
      definition.source = caller.detect{|c|!c.match /core/}
      definition.instance_eval &blk if block_given?
      @definitions[actor_type] = definition

      view_blk = definition.view_blk
      if view_blk
        ActorView.define "#{actor_type}_view".to_sym, &view_blk
      end

      behavior_blk = definition.behavior_blk
      if behavior_blk
        Behavior.define actor_type, &behavior_blk
        definition.has_behavior actor_type
      end
    end

    def definitions
      @definitions ||= {}
    end

  end

  class ActorDefinition
    attr_accessor :behaviors, :attributes, :view_blk, :behavior_blk, :source
    def initialize
      @behaviors = []
      @attributes = []
    end

    def has_behaviors(*behaviors, &blk)
      if block_given?
        collector = MethodMissingCollector.new
        collector.instance_eval &blk
        collector.calls.each do |name, args|
          if args.empty?
            @behaviors << name
          else
            @behaviors << {name => args.first}
          end
        end
      end
      behaviors.each do |beh|
        @behaviors << beh
      end
    end
    alias has_behavior has_behaviors

    def has_attributes(*attributes)
      attributes.each do |att|
        @attributes << att
      end
    end
    alias has_behavior has_behaviors

    def view(&blk)
      @view_blk = blk
    end

    def behavior(&blk)
      @behavior_blk = blk
    end
  end

end
