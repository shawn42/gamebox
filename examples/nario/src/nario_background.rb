require 'actor'

class NarioBackground < Actor
  has_behaviors :graphical,
    {:layered => {:layer => 0, :parallax => 3}}
end
