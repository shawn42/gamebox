require 'inflector'
require 'viewport'
# Mode is a state that the game is in.  (ie intro mode, multiplayer mode,
# single player mode).
class Mode
  extend Publisher
  can_fire_anything

  attr_accessor :level, :drawables, :resource_manager, :sound_manager
  def initialize(input_manager, actor_factory, resource_manager, sound_manager, config_manager, levels)
    @input_manager = input_manager
    @actor_factory = actor_factory
    @resource_manager = resource_manager
    @sound_manager = sound_manager
    @config_manager = config_manager
    res = @config_manager[:screen_resolution]

    @viewport = Viewport.new res[0], res[1]
    @drawables = {}
    @levels = levels
    setup
  end

  def setup
  end

  def start
    @level_number = 0
    clear_drawables
    @level = build_level @levels[@level_number], nil
  end

  def next_level
    @level_number += 1
    clear_drawables
    @level = build_level @levels[@level_number], @level
  end

  def prev_level
    @level_number -= 1
    clear_drawables
    @level = build_level @levels[@level_number], @level
  end

  def restart_level
    clear_drawables
    @level = build_level @levels[@level_number], @level
  end

  def stop
  end

  def build_level(level_def, prev_level_instance)
    level_sym = level_def.keys.first
    begin
      require level_sym.to_s+"_level"
    rescue LoadError => ex
      puts "Load error: #{ex.inspect}"
      puts ex.backtrace.join("\n")
      # maybe we have included it elsewhere
    end
    level_klass = ObjectSpace.const_get(Inflector.camelize(level_sym.to_s+"_level"))
    full_level_def = { :prev_level => prev_level_instance }
    full_level_def.merge! level_def[level_sym] if level_def[level_sym].is_a? Hash
    level = level_klass.new @actor_factory, @resource_manager, @sound_manager, @input_manager, @viewport, full_level_def
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

    level.when :fade_in do |dur|
      fire :fade_in, dur
    end
    level.when :fade_out do |dur|
      fire :fade_out, dur
    end

    level
  end

  def update(time)
    @level.update time if @level
    @viewport.update time
  end

  def draw(target)
    @level.draw target, @viewport.x_offset, @viewport.y_offset

    for parallax_layer in @drawables.keys.sort.reverse
      pd = @drawables[parallax_layer]
      for layer in pd.keys.sort
        for d in pd[layer]
          trans_x = @viewport.x_offset parallax_layer
          trans_y = @viewport.y_offset parallax_layer
          d.draw target, trans_x, trans_y 
        end
      end
    end
  end

  def unregister_drawable(drawable)
    @drawables[drawable.parallax][drawable.layer].delete drawable
  end

  def clear_drawables
    @drawables = {}
  end

  def register_drawable(drawable)
    layer = drawable.layer
    parallax = drawable.parallax
    @drawables[parallax] ||= {}
    @drawables[parallax][layer] ||= []
    @drawables[parallax][layer] << drawable
  end
end

