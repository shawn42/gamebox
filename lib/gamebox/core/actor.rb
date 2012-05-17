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
    atts = methods.sort - Actor.instance_methods
    atts_hash = {}
    atts.each do |att|
      atts_hash[att] = send(att) unless att.to_s.end_with? "="
    end
    "#{self.actor_type}:#{self.object_id} with attributes\n#{atts_hash.inspect}"
  end

  # TODO should this live somewhere else?
  class << self

    def define(actor_type, opts={}, &blk)
      @definitions ||= {}
      definition = ActorDefinition.new
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
    attr_accessor :behaviors, :attributes, :view_blk, :behavior_blk
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
