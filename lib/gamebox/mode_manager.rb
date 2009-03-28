require 'inflector'
require 'mode'
class ModeManager

  constructor :resource_manager, :actor_factory, :input_manager
  def setup
    @modes = {}
    @actor_factory.mode_manager = self
    modes = @resource_manager.load_config('mode_level_config')[:modes]

    @mode_names = []
    for mode_hash in modes
      for mode, levels in mode_hash
        @mode_names << mode
        mode_klass_name = "Mode"
        unless mode == :default
          mode_klass_name = Inflector.camelize mode.to_s+"Mode"
        end
        begin
          require mode.to_s+"_mode"
        rescue LoadError
          # hope it's defined somewhere else
        end
        mode_klass = ObjectSpace.const_get mode_klass_name
        mode_instance = mode_klass.new(@input_manager, @actor_factory, @resource_manager, levels)
        mode_instance.when :next_mode do
          next_mode
        end
        mode_instance.when :prev_mode do
          prev_mode
        end
        add_mode mode, mode_instance
      end
    end
  end

  def next_mode
    index = @mode_names.index @mode
    if index == @mode_names.size-1
      puts "last mode, exiting"
      exit
    end
    change_mode_to @mode_names[index+1]
  end

  def prev_mode
    index = @mode_names.index @mode
    if index == 0
      puts "first mode, exiting"
      exit
    end
    change_mode_to @mode_names[index-1]
  end

  def add_mode(mode_sym, mode_instance)
    @modes[mode_sym] = mode_instance
    @mode = mode_sym unless @mode
    mode_instance
  end

  def change_mode_to(mode, *args)
    @modes[@mode].stop unless @modes[@mode].nil?
    @mode = mode
    @modes[@mode].start *args
  end

  def current_mode
    @modes[@mode]
  end

  def update(time)
    @modes[@mode].update time unless @modes[@mode].nil?
  end

  def draw(target)
    @modes[@mode].draw target unless @modes[@mode].nil?
  end
end
