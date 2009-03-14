class ActorView
  attr_accessor :actor, :mode, :visible
  def initialize(mode,actor)
    @mode = mode
    @actor = actor
    @mode.register_drawable self
    @visible = true

    setup
  end

  def setup
  end
end

