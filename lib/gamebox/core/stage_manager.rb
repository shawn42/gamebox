class StageManager

  construct_with :input_manager, :config_manager, :backstage,
    :this_object_context

  attr_reader :stage_names, :stage_opts

  def initialize
    @stages = {}

    stages = Gamebox.configuration.stages

    @stage_names = []
    @stage_opts = []
    stages.each do |stage|
      if stage.is_a? Hash
        stage_name = stage.keys.first
        opts = stage.values.first
        @stage_names << stage_name
        opts ||= {}
        @stage_opts << opts
      else
        @stage_names << stage
        @stage_opts << {}
      end
    end
  end

  def default_stage
    @stage_names.first
  end

  def next_stage(*args)
    index = @stage_names.index @stage
    if index == @stage_names.size-1
      log "last stage, exiting"
      exit
    end

    switch_to_stage @stage_names[index+1], *args
  end

  def prev_stage(*args)
    index = @stage_names.index @stage
    if index == 0
      log "first stage, exiting"
      exit
    end

    switch_to_stage @stage_names[index-1], *args
  end

  def restart_stage(*args)
    switch_to_stage @stage, *args
  end

  def switch_to_stage(stage_name, *args)
    shutdown_current_stage *args
    activate_new_stage stage_name, *args
  end
  alias :change_stage_to :switch_to_stage

  def current_stage
    @stages[@stage]
  end

  def update(time)
    @stages[@stage].update time unless @stages[@stage].nil?
  end

  def draw(target)
    @stages[@stage].draw target unless @stages[@stage].nil?
  end

  private

  def activate_new_stage(stage_name, *args)
    @stage = stage_name
    @stage_args = args
    @stages[@stage] = create_stage(@stage, @stage_opts[@stage_names.index(@stage)])
    @stages[@stage].curtain_raising *args
  end

  def shutdown_current_stage(*args)
    if @stage and @stages and @stages[@stage]
      current_stage = @stages[@stage]
      current_stage.curtain_dropping *args
      input_manager.clear_hooks(current_stage)
      @stages.delete @stage
      @stage = nil
      @stage_args = nil
    end
  end

  def create_stage(name, opts)
    stage_instance = nil
    this_object_context.in_subcontext do |stage_context|
      name_or_klass = opts[:class] || name
      stage_instance = stage_context["#{name_or_klass}_stage"]
      stage_context[:stage] = stage_instance 
    end
    stage_instance.configure(backstage, opts)

    stage_instance.when :next_stage do |*args|
      next_stage *args
    end
    stage_instance.when :prev_stage do |*args|
      prev_stage *args
    end
    stage_instance.when :restart_stage do |*args|
      restart_stage *args
    end
    stage_instance.when :change_stage do |stage_name, *args|
      switch_to_stage stage_name, *args
    end
    stage_instance
  end


end
