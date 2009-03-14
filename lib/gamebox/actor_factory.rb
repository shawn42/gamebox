class ActorFactory
  attr_accessor :mode_manager
  def initialize(mode_manager)
    @mode_manager = mode_manager
  end

  def build(actor)
    begin
      require actor.to_s
      require actor.to_s+"_view"
    rescue LoadError
      # maybe its included somewhere else
    end
    model_klass_name = Inflector.camelize actor
    model_klass = Object.const_get model_klass_name

    # This seems like a hack, how _should_ he get the level?
    model = model_klass.new @mode_manager.current_mode.level


    view_klass = Object.const_get model_klass_name+"View"
    view_klass.new @mode_manager.current_mode, model if view_klass
    return model
  end
end
