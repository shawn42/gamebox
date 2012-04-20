# BehaviorFactory is in charge of creating all behaviors and placing them in an Actor.
# Everything you want an Actor to _do_ is part of a Behavior. Actors are stupid buckets of data.
# Behaviors can be created by:
#   has_behavior in an Actor's class definition
#   or by dynamically creating one at runtime via another behavior.
class BehaviorFactory

  # Build a behavior. Takes a symbol or a Hash.
  #  add_behavior(:shootable) or add_behavior(:shootable => {:range=>3})
  #  this will create a new instance of Shootable and pass
  #  :range=>3 to it
  def add_behavior(actor, behavior_name, opts = {})
    raise "nil actor" if actor.nil?
    raise "nil behavior definition" if behavior_name.nil?

    behavior_definition = Behavior.definitions[behavior_name]

    raise "unknown behavior #{behavior_name}" unless behavior_definition
    context = actor.this_object_context
    context.in_subcontext do |behavioral_context|
      behavioral_context[:behavior].tap do |behavior|
        reqs = behavior_definition.required_injections
        if reqs
          reqs.each do |req|
            object = context[req]
            behavior.define_singleton_method req do
              components[req] 
            end
            components = behavior.send :components
            components[req] = object
          end
        end

        behavior.define_singleton_method :react_to, behavior_definition.react_to_block if behavior_definition.react_to_block

        deps = behavior_definition.required_behaviors
        if deps
          deps.each do |beh|
            add_behavior actor, beh unless actor.has_behavior?(beh)
          end
        end
        behavior.configure(opts)
        behavior.instance_eval &behavior_definition.setup_block if behavior_definition.setup_block
        actor.add_behavior behavior_name, behavior
      end
    end
  end


end
