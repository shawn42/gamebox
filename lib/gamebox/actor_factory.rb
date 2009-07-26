require 'actor'
require 'graphical_actor_view'

# ActorFactory is responsible for loading all Actors. It passes along required params such as 
# level, input_manager, sound_manager, director, resource_manager. It also creates the ActorView 
# associated with the Actor and registers it to the Mode be drawn. 
class ActorFactory
  constructor :input_manager, :sound_manager

  attr_accessor :mode_manager, :director
  
  # Returns a hash of actor params {:model_klass=>k, :view_klass=>v}. This is for performance reasons.
  def cached_actor_def(actor)
    @actor_cache ||= {}
    cached_actor = @actor_cache[actor]
    return cached_actor if cached_actor

    
    model_klass_name = Inflector.camelize actor
    begin
      model_klass = Object.const_get model_klass_name
    rescue NameError
      # not there yet
      begin
        require actor.to_s
        require actor.to_s+"_view"
      rescue LoadError => ex
        # maybe its included somewhere else
      ensure
        model_klass = Object.const_get model_klass_name
      end
    end
    
    begin
      view_klass = Object.const_get model_klass_name+"View"
    rescue Exception => ex
      # hrm...
    end
    
    actor_def = {
      :model_klass => model_klass,
      :view_klass => view_klass
    }
    @actor_cache[actor] = actor_def
    actor_def
  end

  # returns the newly created Actor after it and its ActorView has been created.
  def build(actor, level, opts={})
    actor_def = cached_actor_def actor

    basic_opts = {
      :level => level,
      :input => @input_manager,
      :sound => @sound_manager,
      :director => @director,
      :resources => level.resource_manager
    }
    merged_opts = basic_opts.merge(opts)

    model = actor_def[:model_klass].new merged_opts 

    view_klass = opts[:view]
    view_klass ||= actor_def[:view_klass]
    
    if model.is? :animated or model.is? :graphical or model.is? :physical
      view_klass ||= GraphicalActorView
    end
    view_klass.new @mode_manager.current_mode, model if view_klass
    
    model.show unless opts[:hide]

    return model
  end
end
