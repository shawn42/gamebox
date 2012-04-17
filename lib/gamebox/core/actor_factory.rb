
# ActorFactory is responsible for loading all Actors. It also creates the ActorView 
# associated with the Actor and registers it to the Stage be drawn. 
class ActorFactory
  construct_with :input_manager, :wrapped_screen, :resource_manager,
    :behavior_factory, :this_object_context

  # returns the newly created Actor after it and its ActorView has been created.
  def build(actor, opts={})
    merged_opts = opts.merge(actor_type: actor)

    model = nil
    this_object_context.in_subcontext do |actor_context|
      begin
        model = actor_context[:actor]

        actor_definition = Actor.definitions[actor]
        raise "#{actor} not found in Actor.definitions" if actor_definition.nil?
        actor_definition.behaviors.each do |behavior|
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

          # TODO
          # have animated, graphical, physical set a view attr on actor
          view_klass = opts[:view] || model.do_or_do_not(:view) || "#{actor}_view"

          view_definition = ActorView.definitions[view_klass.to_sym]
          if view_definition
            view = actor_context[:actor_view]

            reqs = view_definition.required_injections
            if reqs
              reqs.each do |req|
                object = actor_context[req]
                view.define_singleton_method req do
                  components[req] 
                end
                components = view.send :components
                components[req] = object
              end
            end

            view.define_singleton_method :draw, &view_definition.draw_block if view_definition.configure_block
            view.define_singleton_method :configure, &view_definition.configure_block if view_definition.configure_block

            view.configure

            # TODO this reads like butt!
            model.add_behavior :visible, behavior_factory.add_behavior(model, :visible, view: view)
          end
        rescue Exception => e
          log "could not find view class for #{actor} with key #{view_klass}"
        end

        model.react_to :show unless opts[:hide]
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
