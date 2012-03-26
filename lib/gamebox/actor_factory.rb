
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
        model = actor_context[actor]

        # ============= STOLEN FROM ACTOR =====================
        # add our classes behaviors and parents behaviors
        behavior_defs = {}
        ordered_behaviors = []

        actor_klasses = class_ancestors(model)
        actor_klasses.reverse.each do |actor_klass|
          actor_behaviors = actor_klass.behaviors.dup
          actor_behaviors.each do |behavior|

            behavior_sym = behavior
            behavior_opts = {}
            if behavior.is_a?(Hash)
              behavior_sym =  behavior.keys.first
              behavior_opts = behavior[behavior_sym]
            end

            # TODO does an actor really need to know its list of behaviors?... probably..
            # TODO clean up behaviors on is_no_longer
            ordered_behaviors << behavior_sym unless ordered_behaviors.include? behavior_sym
            behavior_defs[behavior_sym] = behavior_opts
          end
        end

        ordered_behaviors.each do |behavior|
          # TODO make this use the actor_context
          beh_opts = behavior_defs[behavior] || {}
          model.behaviors[behavior] = behavior_factory.add_behavior model, behavior, beh_opts
        end
        # ============= STOLEN FROM ACTOR =====================

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

        model.show unless opts[:hide]
      rescue Exception => e
        # binding.pry
        raise "#{actor} not found: #{e.inspect}"
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
