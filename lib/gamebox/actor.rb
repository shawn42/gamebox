require 'publisher'
# Actor represent a game object.
# Actors can have behaviors added and removed from them.
class Actor
  extend Publisher

  attr_accessor :behaviors, :x, :y, :level, :input_manager,
    :resource_manager, :alive

  can_fire_anything

  def initialize(level, input_manager, resource_manager)
    @x = 0
    @y = 0
    @level = level
    @input_manager = input_manager
    @resource_manager = resource_manager
    @alive = true

    @behaviors = {}
    # add our classes behaviors
    class_behaviors = self.class.behaviors.dup
    for behavior in class_behaviors
      is behavior
    end
    setup
  end

  def setup
  end

  def alive?
    @alive
  end

  def remove_self
    @alive = false
    fire :remove_me
    @input_manager.unsubscribe_all self
  end

  def is?(behavior_sym)
    !@behaviors[behavior_sym].nil?
  end

  def is(behavior_def)
    behavior_sym = behavior_def.is_a?(Hash) ? behavior_def.keys.first : behavior_def
    behavior_opts = behavior_def.is_a?(Hash) ? behavior_def.values.first : []
    begin
      require behavior_sym.to_s;
    rescue LoadError
      # maybe its included somewhere else
    end
    klass = Object.const_get Inflector.camelize(behavior_sym)
    @behaviors[behavior_sym] = klass.new self, behavior_opts
  end

  def is_no_longer(behavior_sym)
    @behaviors.delete behavior_sym
  end

  def update_behaviors(time)
    for behavior in @behaviors.values
      behavior.update time
    end
  end

  # to be defined in child class
  def update(time)
    # TODO maybe use a callback list for child classes
    update_behaviors time
  end

  # to be defined in child class
  def draw(target)
  end

  # Get a metaclass for this class
  def self.metaclass; class << self; self; end; end

  # magic
  metaclass.instance_eval do
    define_method( :behaviors ) do
      @behaviors ||= []
    end
    define_method( :has_behaviors ) do |*args|
      @behaviors ||= []
      for a in args
        @behaviors << a
      end
      @behaviors
    end
  end
end
