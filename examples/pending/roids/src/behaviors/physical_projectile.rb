define_behavior :physical_projectile do
  requires :director
  setup do
    actor.has_attributes speed: 300,
                         power: 500,
                         dir: nil

    director.when :update do |time|
      actor.power -= time
      if actor.power <= 0
        actor.remove
      end
      actor.body.apply_impulse(actor.dir * time * actor.speed, ZERO_VEC_2) if actor.body.v.length < 400
    end
  end

end
