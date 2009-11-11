require 'inflector'
require 'stage'
class StageManager

  constructor :resource_manager, :actor_factory, :input_manager,
    :sound_manager, :config_manager

  def setup
    @stages = {}

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
        add_stage stage, stage_instance
      end
    end
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

  def update(time)
    @stages[@stage].update time unless @stages[@stage].nil?
  end

  def draw(target)
    @stages[@stage].draw target unless @stages[@stage].nil?
  end
end
