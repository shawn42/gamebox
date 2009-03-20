class ActorFactory
  constructor :input_manager

  attr_accessor :mode_manager

  def build(actor, level, opts={})
    begin
      require actor.to_s
      require actor.to_s+"_view"
    rescue LoadError
      # maybe its included somewhere else
    end
    model_klass_name = Inflector.camelize actor
    model_klass = Object.const_get model_klass_name

    # This seems like a hack, how _should_ he get the level?
    model = model_klass.new level, @input_manager, level.resource_manager

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
    return model
  end
end
