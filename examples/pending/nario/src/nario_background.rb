

class NarioBackground < Actor
  has_behaviors :graphical,
    {:layered => {:layer => 0, :parallax => Float::INFINITY}}
end
