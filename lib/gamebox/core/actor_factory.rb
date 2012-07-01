
# ActorFactory is responsible for loading all Actors. It also creates the ActorView 
# associated with the Actor and registers it to the Stage be drawn. 
class ActorFactory
  construct_with :input_manager, :wrapped_screen, :resource_manager,
    :behavior_factory, :actor_view_factory, :this_object_context

  # returns the newly created Actor after it and its ActorView has been created.
  def build(actor, opts={})
    merged_opts = opts.merge(actor_type: actor)

    model = nil
    this_object_context.in_subcontext do |actor_context|
      begin
        model = actor_context[:actor]

        actor_definition = Actor.definitions[actor]
        raise "#{actor} not found in Actor.definitions" if actor_definition.nil?
        model.configure(merged_opts)

        actor_definition.attributes.each do |attr|
          model.has_attributes attr
        end

        actor_definition.behaviors.each do |behavior|
          beh_opts = {}
          beh_key = behavior

          if behavior.is_a?(Hash)
            beh_opts = behavior.values.first
            beh_key = behavior.keys.first
          end

          model.add_behavior(beh_key, beh_opts)
        end

        actor_view_factory.build model, opts
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
