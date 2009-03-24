require 'inflector'
# Mode is a state that the game is in.  (ie intro mode, multiplayer mode,
# single player mode).
class Mode
  extend Publisher
  can_fire_anything

  attr_accessor :level, :drawables, :resource_manager
  def initialize(actor_factory, resource_manager, levels)
    @actor_factory = actor_factory
    @resource_manager = resource_manager
    @drawables = {}
    @levels = levels
    setup
  end

  def setup
  end

  def start
    @level_number = 0
    clear_drawables
    @level = build_level @levels[@level_number]
  end

  def next_level
    @level_number += 1
    clear_drawables
    @level = build_level @levels[@level_number]
  end

  def prev_level
    @level_number -= 1
    clear_drawables
    @level = build_level @levels[@level_number]
  end

  def restart_level
    clear_drawables
    @level = build_level @levels[@level_number]
  end

  def stop
  end

  def build_level(level_def)
    level_sym = level_def.keys.first
    begin
      require level_sym.to_s+"_level"
    rescue LoadError
      # maybe we have included it elsewhere
    end
    level_klass = ObjectSpace.const_get(Inflector.camelize(level_sym.to_s+"_level"))
    level = level_klass.new @actor_factory, @resource_manager, level_def[level_sym]
    level.when :restart_level do
      restart_level
    end
    level.when :next_level do
      if @level_number == @levels.size-1
        fire :next_mode
      else
        next_level
      end
    end
    level.when :prev_level do
      if @level_number == 0
        fire :prev_mode
      else
        prev_level
      end
    end

    level
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
    @drawables.delete drawable.object_id
  end

  def clear_drawables
    @drawables = {}
  end

  def register_drawable(drawable)
    @drawables[drawable.object_id] = drawable
  end
end

