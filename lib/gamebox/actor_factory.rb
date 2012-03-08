
# ActorFactory is responsible for loading all Actors. It also creates the ActorView 
# associated with the Actor and registers it to the Stage be drawn. 
class ActorFactory
  construct_with :input_manager, :wrapped_screen, :resource_manager,
    :this_object_context

  # returns the newly created Actor after it and its ActorView has been created.
  def build(actor, stage, opts={})
    basic_opts = { :actor_type => actor }
    merged_opts = basic_opts.merge(opts)

    model = nil
    this_object_context.in_subcontext do |stage_context|
      begin
        model = stage_context[actor]
        model.configure(merged_opts)

        # TODO how can I ask Conject if something can be found w/o just rescueing here?
        begin
          view_klass = opts[:view]

          if model.is? :animated or model.is? :graphical or model.is? :physical
            view_klass ||= "graphical_actor_view"
          else
            view_klass ||= "#{actor}_view"
          end

          view = stage_context[view_klass]
          view.configure model
        rescue Exception => e
          log "could not find view class for #{actor} with key #{view_klass}"
        end

      model.show unless opts[:hide]
      rescue Exception => e
        raise "#{actor} not found: #{e.inspect}"
      end
    end
    model
  end
end
