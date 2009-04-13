require 'actor'
require 'graphical_actor_view'

class NarioMidView < GraphicalActorView
  has_props :layer => 1
end

class NarioMid < Actor
  has_behaviors :graphical
end
