class ActorView
  attr_accessor :actor, :mode, :layer
  def initialize(mode,actor)
    @mode = mode
    @actor = actor

    
    class_props = self.class.props.dup

    layer = 1
    if class_props and class_props[:layer]
      layer = class_props[:layer]
    end

    @layer = layer
    actor.when :remove_me do
      @mode.unregister_drawable self
    end
    @mode.register_drawable self

    setup
  end

  def setup
  end

  # magic
  metaclass.instance_eval do
    define_method( :props ) do
      @props ||= {}
    end
    define_method( :has_props ) do |prop_hash|
      @props = prop_hash
      @props ||= {}
    end
  end
end

