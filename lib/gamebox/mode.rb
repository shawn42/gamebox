require 'inflector'
# Mode is a state that the game is in.  (ie intro mode, multiplayer mode,
# single player mode).
class Mode
  attr_accessor :level, :drawables
  def initialize(actor_factory, levels)
    @actor_factory = actor_factory
    @drawables = {}
    @levels = levels
    setup
  end

  def setup
  end

  def start
    @level = build_level @levels.pop
  end

  def stop
  end

  def build_level(level_sym)
    begin
      require level_sym.to_s+"_level"
    rescue LoadError
      # maybe we have included it elsewhere
    end
    level_klass = ObjectSpace.const_get(Inflector.camelize(level_sym.to_s+"_level"))
    level = level_klass.new @actor_factory
  end

  def update(time)
    @level.update time if @level
  end

  def draw(target)
    @level.draw target
    for d in @drawables.values
      d.draw target
    end
  end

  def unregister_drawable(drawable)
    @drawables.delete drawable
  end

  def register_drawable(drawable)
    @drawables[drawable] = drawable
  end
end

