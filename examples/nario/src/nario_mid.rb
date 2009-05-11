require 'actor'

class NarioMid < Actor
  has_behaviors :graphical,
    {:layered => {:layer => 0, :parallax => 2}}
end
