require 'inflector'
require 'mode'
require 'publisher'
class ModeManager
  extend Publisher
  can_fire :faded_in, :faded_out

  constructor :resource_manager, :actor_factory, :input_manager,
    :sound_manager, :config_manager

  def setup
    @modes = {}
    @fade_counter = 2000
    @fade_out_ttl = 0
    @fade_in_ttl = 0

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
        mode_instance = mode_klass.new(@input_manager, @actor_factory, @resource_manager, @sound_manager, @config_manager, levels)
        mode_instance.when :next_mode do
          next_mode
        end
        mode_instance.when :prev_mode do
          prev_mode
        end
        mode_instance.when :fade_out do |dur|
          fade_out dur
        end
        mode_instance.when :fade_in do |dur|
          fade_in dur
        end
        add_mode mode, mode_instance
      end
    end
  end

  def fade_out(duration)
    @fade_out_ttl = duration
  end

  def fade_in(duration)
    @fade_in_ttl = duration
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
    @prev_mode = @modes[@mode]
    unless @prev_mode.nil?
      @prev_mode.stop 
    end
    @mode = mode
    @modes[@mode].start *args
  end

  def current_mode
    @modes[@mode]
  end

  def update(time)
    if @fade_out_ttl > 0
#      was_fading_out = true
      @fade_out_ttl -= time
    elsif @fade_in_ttl > 0
      @fade_in_ttl -= time
    end
#    if @fade_out_ttl < 0 && was_fading_out
#      @fade_in_ttl = @fade_counter 
#    end
    @modes[@mode].update time unless @modes[@mode].nil?
  end

  def draw(target)
    if @fade_out_ttl > 0
      if @prev_mode.nil?
        @fade_out_ttl = 0
      else
        @prev_mode.draw target 
      end
      alpha = (1-@fade_out_ttl/@fade_counter.to_f) * 255
      target.draw_box_s [0,0], target.screen.size, [0,0,0,alpha]
    else
      @modes[@mode].draw target unless @modes[@mode].nil?
    end

    if @fade_in_ttl > 0
      alpha = @fade_in_ttl/@fade_counter.to_f * 255
      target.draw_box_s [0,0], target.screen.size, [0,0,0,alpha]
    end
  end
end
