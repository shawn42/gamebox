class ActorDefinition
  attr_accessor :behaviors, :attributes, :view_blk, :behavior_blk, :source
  def initialize
    @behaviors = []
    @attributes = []
  end

  # Setup default behaviors for this Actor
  # 
  #  # takes a block with method missing magic
  #  has_behaviors do
  #    shooter range: 12
  #  end
  #
  #  # takes a list of optionless behaviors
  #  has_behaviors :jumper, :shielded
  #
  #  # takes a hash of behavior name to options
  #  has_behaviors shooter: {range: 12}
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

  # Setup observable attributes for the Actor and optionally default values
  #
  #  # takes list of attributes (values will be nil)
  #  has_attributes :x, :y
  #  
  #  # takes hash of attributes with values
  #  has_attributes x: 5, y: 12
  def has_attributes(*attributes)
    attributes.each do |att|
      @attributes << att
    end
  end
  alias has_attribute has_attributes

  # Defines an ActorView for this Actor with the correct name. 
  # 
  # Exactly the same as calling define_actor_view with :my_actor_view.
  #
  # Do not call more than once.
  #
  # @see GameboxDSL#define_actor_view
  def view(&blk)
    @view_blk = blk
  end

  # Defines a Behavior with the Actor type as the name and adds it to the Actor.
  #
  # Exactly the same as calling define_behavior with :my_actor, and adding the
  # behavior to the Actor.
  #
  # Do not call more than once.
  def behavior(&blk)
    @behavior_blk = blk
  end
end

