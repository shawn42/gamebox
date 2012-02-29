
# ActorFactory is responsible for loading all Actors. It passes along required params such as 
# stage, input_manager, director, resource_manager. It also creates the ActorView 
# associated with the Actor and registers it to the Stage be drawn. 
class ActorFactory
  construct_with :input_manager, :wrapped_screen

  attr_accessor :director
  
  # Returns a hash of actor params {:model_klass=>k, :view_klass=>v}. This is for performance reasons.
  def cached_actor_def(actor)
    @actor_cache ||= {}
    cached_actor = @actor_cache[actor]
    return cached_actor if cached_actor

    model_klass = ClassFinder.find(actor)
    raise "#{actor} not found" unless model_klass
    
    view_klass = ClassFinder.find("#{actor}_view")
    
    actor_def = {
      :model_klass => model_klass,
      :view_klass => view_klass
    }
    @actor_cache[actor] = actor_def
    actor_def
  end

  # returns the newly created Actor after it and its ActorView has been created.
  def build(actor, stage, opts={})
    actor_def = cached_actor_def actor

    basic_opts = {
      :stage => stage,
      :input => input_manager,
      :director => @director,
      :resources => stage.resource_manager,
      :actor_type => actor,
      :wrapped_screen => wrapped_screen
    }
    merged_opts = basic_opts.merge(opts)
    model = actor_def[:model_klass].new merged_opts 

    view_klass = opts[:view]
    view_klass ||= actor_def[:view_klass]
    
    if model.is? :animated or model.is? :graphical or model.is? :physical
      view_klass ||= GraphicalActorView
    end
    
    view_klass.new stage, model, wrapped_screen if view_klass
    
    model.show unless opts[:hide]

    return model
  end
end
