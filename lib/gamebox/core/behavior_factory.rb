
# This class is obsolete, but retained for backward compatibility.
# Use Actor#add_behavior instead.
class BehaviorFactory

  # Obsolete. Use Actor#add_behavior instead.
  def add_behavior(actor, behavior_name, opts = {})
    actor.add_behavior behavior_name, opts
  end

end
