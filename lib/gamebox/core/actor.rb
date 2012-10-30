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

  # Add a behavior to the actor, perhaps with certain options.
  #
  # Examples:
  #   add_behavior(:shootable)
  #   add_behavior(:shootable, :range=>3)
  def add_behavior(behavior_name, opts={})
    raise "nil behavior definition" if behavior_name.nil?

    # For backward compatibility. The second arg used to be an already
    # built behavior, passed from BehaviorFactory#add_behavior.
    unless opts.is_a?(Hash)
      @behaviors[behavior_name] = opts
      return
    end

    bdef = Behavior.definitions[behavior_name]
    raise "unknown behavior #{behavior_name}" unless bdef
    deps = bdef.required_behaviors
    if deps
      deps.each do |dep|
        add_behavior(dep) unless has_behavior?(dep)
      end
    end

    @behaviors[behavior_name] = build_behavior(behavior_name, opts)
  end

  # Build and return a new behavior using the given behavior_name and
  # opts. The returned behavior should only be used with this actor.
  def build_behavior(behavior_name, opts)
    bdef = Behavior.definitions[behavior_name]
    raise "unknown behavior #{behavior_name}" unless bdef

    context = this_object_context
    behavior = context.in_subcontext do |sub|
      sub[:behavior]
    end

    reqs = bdef.required_injections
    if reqs
      reqs.each do |req|
        object = context[req]
        behavior.define_singleton_method(req) do
          components[req]
        end
        components = behavior.send :components
        components[req] = object
      end
    end

    helpers = bdef.helpers_block
    if helpers
      helpers_module = Module.new &helpers
      behavior.extend helpers_module
    end

    if bdef.react_to_block
      behavior.define_singleton_method :react_to, bdef.react_to_block
    end

    behavior.configure(opts)

    if bdef.setup_block
      behavior.instance_eval &bdef.setup_block
    end

    behavior
  end
  private :build_behavior

  def remove_behavior(name)
    @behaviors.delete(name).tap do |behavior|
      behavior.react_to :remove if behavior
    end
  end

  def react_to(message, *opts, &blk)
    # TODO cache the values array?
    @behaviors.values.each do |behavior|
      behavior.react_to(message, *opts, &blk)
    end
    nil
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
    when String, Float, Fixnum, TrueClass, FalseClass, Vector2
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
