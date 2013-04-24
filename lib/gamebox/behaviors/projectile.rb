define_behavior :projectile do

  requires :director
  requires_behaviors :positioned
  setup do
    actor.has_attributes vel_x: 0,
                         vel_y: 0

    director.when :update do |time, secs|
      actor.x += (actor.vel_x * secs)
      actor.y += (actor.vel_y * secs)
    end

    reacts_with :remove
  end

  helpers do
    def remove
      director.unsubscribe_all self
    end
  end

end
