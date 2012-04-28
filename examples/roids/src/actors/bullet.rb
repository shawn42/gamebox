
define_actor :bullet do
  has_behaviors :physical_projectile, :animated, :physical => {:shape => :circle, 
    :mass => 10,
    :radius => 3}

end
