require 'actor'
require 'graphical_actor_view'

class NarioBackgroundView < GraphicalActorView
  has_props :layer => 0
end

class NarioBackground < Actor
  has_behaviors :graphical
end
