class ActorFactory
  constructor :input_manager, :sound_manager

  attr_accessor :mode_manager, :director

  def build(actor, level, opts={})
    begin
      require actor.to_s
      require actor.to_s+"_view"
    rescue LoadError
      # maybe its included somewhere else
    end
    model_klass_name = Inflector.camelize actor
    model_klass = Object.const_get model_klass_name

    basic_opts = {
      :level => level,
      :input => @input_manager,
      :sound => @sound_manager,
      :resources => level.resource_manager
    }
    merged_opts = basic_opts.merge(opts)

    model = model_klass.new basic_opts 

    view_klass = opts[:view]
    if view_klass
      view_klass.new @mode_manager.current_mode, model if view_klass
    else
      begin
        view_klass = Object.const_get model_klass_name+"View"
        view_klass.new @mode_manager.current_mode, model if view_klass
      rescue Exception => ex
        # if the view class doesn't exist, don't create it
      end
    end

    # Register our new actor with the system
    director.add_actor model

    return model
  end
end
