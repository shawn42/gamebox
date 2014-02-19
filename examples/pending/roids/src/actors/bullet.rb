define_behavior :view do
  setup do
    actor.has_attributes view: @opts
  end
end

define_actor :bullet do
  has_behaviors :physical_projectile, :animated, :physical => {:shape => :circle, 
    :mass => 10,
    :radius => 3}

  has_behaviors view: 'graphical_actor_view'

end
