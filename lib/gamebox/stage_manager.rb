require 'inflector'
require 'stage'
class StageManager

  constructor :resource_manager, :actor_factory, :input_manager,
    :sound_manager, :config_manager

  def setup
    @stages = {}
    @fade_counter = 2000
    @fade_out_ttl = 0
    @fade_in_ttl = 0

    @actor_factory.stage_manager = self
    stages = @resource_manager.load_config('stage_config')[:stages]

    @stage_names = []
    for stage_hash in stages
      for stage, levels in stage_hash
        @stage_names << stage
        stage_klass_name = "Stage"
        unless stage == :default
          stage_klass_name = Inflector.camelize stage.to_s+"Stage"
        end
        begin
          require stage.to_s+"_stage"
        rescue LoadError
          # hope it's defined somewhere else
        end
        stage_klass = ObjectSpace.const_get stage_klass_name
        stage_instance = stage_klass.new(@input_manager, @actor_factory, @resource_manager, @sound_manager, @config_manager, levels)
        stage_instance.when :next_stage do
          next_stage
        end
        stage_instance.when :prev_stage do
          prev_stage
        end
        stage_instance.when :fade_out do |dur|
          fade_out dur
        end
        stage_instance.when :fade_in do |dur|
          fade_in dur
        end
        add_stage stage, stage_instance
      end
    end
  end

  def fade_out(duration)
    @fade_out_ttl = duration
  end

  def fade_in(duration)
    @fade_in_ttl = duration
  end

  def next_stage
    index = @stage_names.index @stage
    if index == @stage_names.size-1
      puts "last stage, exiting"
      exit
    end
    change_stage_to @stage_names[index+1]
  end

  def prev_stage
    index = @stage_names.index @stage
    if index == 0
      puts "first stage, exiting"
      exit
    end
    change_stage_to @stage_names[index-1]
  end

  def add_stage(stage_sym, stage_instance)
    @stages[stage_sym] = stage_instance
    @stage = stage_sym unless @stage
    stage_instance
  end

  def change_stage_to(stage, *args)
    @prev_stage = @stages[@stage]
    unless @prev_stage.nil?
      @prev_stage.stop 
    end
    @stage = stage
    @stages[@stage].start *args
  end

  def current_stage
    @stages[@stage]
  end

  def update_fades(time)
    if @fade_out_ttl > 0
      @fade_out_ttl -= time
      @stages[@stage].faded_out if @fade_out_ttl < 0 
    elsif @fade_in_ttl > 0
      @fade_in_ttl -= time
      @stages[@stage].faded_in if @fade_in_ttl < 0 
    end
  end

  def update(time)
    update_fades time
    @stages[@stage].update time unless @stages[@stage].nil?
  end

  def draw(target)
    if @fade_out_ttl > 0
      if @prev_stage.nil?
        @fade_out_ttl = 0
      end
      alpha = (1-@fade_out_ttl/@fade_counter.to_f) * 255
      target.draw_box_s [0,0], target.screen.size, [0,0,0,alpha]
    else
      @stages[@stage].draw target unless @stages[@stage].nil?
    end

    if @fade_in_ttl > 0
      alpha = @fade_in_ttl/@fade_counter.to_f * 255
      target.draw_box_s [0,0], target.screen.size, [0,0,0,alpha]
    end
  end
end
