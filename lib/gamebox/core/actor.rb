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
  attr_accessor :actor_type

  def initialize
    has_attribute :alive, true
    @behaviors = {}
  end

  def configure(opts={}) # :nodoc:
    self.actor_type = opts.delete(:actor_type)
    has_attributes opts
  end

  # Adds the behavior object to the Actor. You should never use
  # this method in your game.
  def add_behavior(name, behavior)
    @behaviors[name] = behavior
  end
  
  # Removes the behavior object from the Actor. 
  # Sends :remove reaction to the removed behavior.
  # You should never use this method in your game.
  def remove_behavior(name)
    @behaviors.delete(name).tap do |behavior|
      behavior.react_to :remove if behavior
    end
  end

  # Returns true if the Actor has the named behavior.
  #
  # This is mostly used internally by Gamebox. You should favor
  # not knowing behaviors if possible and instead look at the
  # Actor's attributes via #do_or_do_not
  def has_behavior?(name)
    @behaviors[name]
  end

  # Propogates the reaction to all behaviors of the Actor.
  # Any behavior can react to these messages.
  #
  # @see Behavior#reacts_with
  def react_to(message, *opts, &blk)
    # TODO cache the values array?
    @behaviors.values.each do |behavior|
      behavior.react_to(message, *opts, &blk)
    end
    nil
  end

  def emit(event, *args)
    fire event, *args
  end

  # Sets the Actor to no longer being alive. 
  # 
  # Sends a :remove reaction to all the Actor's behaviors.
  # Emits a :remove_me event.
  def remove
    self.alive = false
    react_to :remove
    emit :remove_me
  end

  def controller
    # TODO conject should have a lazily loaded dependency mechanism
    @input_mapper ||= this_object_context[:input_mapper]
  end

  def to_s
    """
    #{actor_type}:#{self.object_id}
    Behaviors:
    #{@behaviors.keys.sort}
    Attributes:
    #{attributes.map{|name, val| "#{name}: #{printable_value(val)}"}.join("\n")} """
  end
  alias pretty_inspect to_s

  private
  def printable_value(value)
    case value
    when String, Float, Fixnum, TrueClass, FalseClass, Vector2, Symbol
      value
    when Array
      value.map do |pv|
        printable_value(pv)
      end
    else
      value.class
    end
  end

  class << self

    def define(actor_type, opts={}, &blk)
      @definitions ||= {}
      raise "Actor [#{actor_type}] already defined at #{@definitions[actor_type].source}" if @definitions[actor_type]

      definition = ActorDefinition.new
      # TODO evaluate the perf of doing this
      definition.source = caller.detect{|c|!c.match /core/}
      definition.instance_eval &blk if block_given?

      view_blk = definition.view_blk
      if view_blk
        ActorView.define "#{actor_type}_view".to_sym, &view_blk
      end

      behavior_blk = definition.behavior_blk
      if behavior_blk
        Behavior.define actor_type, &behavior_blk
        definition.has_behavior actor_type
      end

      @definitions[actor_type] = definition
    end

    def definitions
      @definitions ||= {}
    end

  end


end
