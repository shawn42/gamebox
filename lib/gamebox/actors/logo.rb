require 'actor'
class Logo < Actor
  has_behaviors :graphical, 
  :layered => {:layer => 999}
end
