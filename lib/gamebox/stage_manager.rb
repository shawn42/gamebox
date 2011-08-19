class StageManager

  constructor :resource_manager, :actor_factory, :input_manager,
    :sound_manager, :config_manager

  def setup
    @stages = {}
    @backstage = Backstage.new

    @actor_factory.stage_manager = self
    stages = @config_manager.load_config('stage_config')[:stages]

    @stage_names = []
    @stage_opts = []
    stages.each do |stage|
      stage_name = stage.keys.first
      opts = stage.values.first
      @stage_names << stage_name
      opts ||= {}
      @stage_opts << opts
    end
  end
  
  def lookup_stage_class(stage_name)
    index = @stage_names.index stage_name
    opts = @stage_opts[index]

    name = opts[:class]
    name ||= stage_name
    stage_klass_name ||= Inflector.camelize name.to_s+"Stage"

    begin
      require name.to_s+"_stage"
    rescue LoadError => ex
      STDERR.puts ex
      # TODO hrm.. should this get logged
      # hope it's defined somewhere else
    end
    stage_klass = ObjectSpace.const_get stage_klass_name
  end

  def create_stage(name, opts)
    stage_instance = lookup_stage_class(name).new(@input_manager, @actor_factory, @resource_manager, @sound_manager, @config_manager, @backstage, opts)

    stage_instance.when :next_stage do |*args|
      next_stage *args
    end
    stage_instance.when :prev_stage do |*args|
      prev_stage *args
    end
    stage_instance.when :restart_stage do |*args|
      restart_stage *args
    end
    
    stage_instance
  end

  def next_stage(*args)
    index = @stage_names.index @stage
    if index == @stage_names.size-1
      puts "last stage, exiting"
      exit
    end
    stage = @stages.delete @stage_names[index+1]
    @input_manager.clear_hooks stage

    change_stage_to @stage_names[index+1], *args
  end

  def prev_stage(*args)
    index = @stage_names.index @stage
    if index == 0
      puts "first stage, exiting"
      exit
    end
    stage = @stages.delete @stage_names[index-1]
    @input_manager.clear_hooks stage
    change_stage_to @stage_names[index-1], *args
  end

  def restart_stage(*args)
    current_stage.curtain_dropping *args
    index = @stage_names.index @stage

    stage = @stages.delete @stage_names[index]
    @input_manager.clear_hooks stage

    change_stage_to @stage, *args
  end

  def change_stage_to(stage, *args)
    @prev_stage = @stages[@stage]
    unless @prev_stage.nil?
      @prev_stage.curtain_dropping *args
    end
    @stage = stage
    @stage_args = args
    unless @stages[@stage]
      @stages[@stage] = create_stage(@stage, @stage_opts[@stage_names.index(@stage)])
    end
    @stages[@stage].curtain_raising *args
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
