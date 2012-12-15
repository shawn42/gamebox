
# ActorViewFactory is responsible for loading all ActorViews. It creates the ActorView 
# associated with the Actor and registers it to the Stage be drawn. 
class ActorViewFactory
  construct_with :behavior_factory

  # builds a new ActorView and configures it per its definition that is setup via ActorView.define
  def build(actor, opts={})
    # TODO  have animated, graphical, physical set a view attr on actor
    view_klass = opts[:view] || actor.do_or_do_not(:view) || "#{actor.actor_type}_view"

    view_definition = ActorView.definitions[view_klass.to_sym]
    view = nil
    if view_definition
      actor_context = actor.this_object_context
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

      view.define_singleton_method :draw, &view_definition.draw_block if view_definition.draw_block
      if view_definition.configure_block
        view.define_singleton_method :configure, &view_definition.configure_block 
        view.configure
      end

      helpers = view_definition.helpers_block
      if helpers
        helpers_module = Module.new &helpers
        view.extend helpers_module
      end

      behavior_factory.add_behavior(actor, :visible, view: view)
      actor.react_to :show unless opts[:hide]
    end
    view
  end

end
