
# ActorFactory is responsible for loading all Actors. It also creates the ActorView 
# associated with the Actor and registers it to the Stage be drawn. 
class ActorFactory
  construct_with :input_manager, :wrapped_screen, :resource_manager,
    :behavior_factory, :this_object_context

  # returns the newly created Actor after it and its ActorView has been created.
  def build(actor, stage, opts={})
    basic_opts = { :actor_type => actor }
    merged_opts = basic_opts.merge(opts)

    model = nil
    this_object_context.in_subcontext do |actor_context|
      begin
        model = actor_context[:actor]

        Actor.definitions[actor].behaviors.each do |behavior|
          beh_opts = {}
          beh_key = behavior

          if behavior.is_a?(Hash)
            beh_opts = behavior.values.first
            beh_key = behavior.keys.first
          end

          model.add_behavior beh_key, behavior_factory.add_behavior(model, beh_key, beh_opts)
        end

        model.configure(merged_opts)

        # TODO how can I ask Conject if something can be found w/o just rescueing here?
        begin
          view_klass = opts[:view]

          if model.is? :animated or model.is? :graphical or model.is? :physical
            view_klass ||= "graphical_actor_view"
          else
            view_klass ||= "#{actor}_view"
          end

          view = actor_context[view_klass]
          view.configure model
        rescue Exception => e
          log "could not find view class for #{actor} with key #{view_klass}"
        end

        # TODO figure this out too
        # model.show unless opts[:hide]
      rescue Exception => e
        # binding.pry
        raise """
          #{actor} not found: 
          #{e.inspect}
          #{e.backtrace[0..6].join("\n")}
        """
      end
    end
    model
  end

  def class_ancestors(actor)
    klass = actor.class
    [].tap { |actor_klasses|
      while klass != Actor
        actor_klasses << klass
        klass = klass.superclass
      end
    }
  end

end
