define_actor_view :particle_system_view do
  draw do |target, x_off, y_off, z|
    ax = actor.x + x_off
    ay = actor.y + y_off
    actor.particles.each do |part|
      target.draw_circle_filled part.x,part.y, 3, [part.r,part.g,part.b,part.a], z
    end
  end
end

# TODO constructor struct thing here?
Particle = Struct.new(:x,:y,:r,:g,:b,:a,:dir,:speed,:ttl)

define_behavior :particles do

  # DEFAULT_SETTINGS = {
  #   :active_particle_limit => 90,
  #   :total_particles => 200
  # }

  requires :director
  setup do
    actor.has_attributes active_particle_limit: 350,
                         max_particle_created_per_step: 90,
                         total_particles: 400,
                         particles: []
    director.when :update do |time|
      update time
    end

  end

  helpers do
    def create_particle
      part = Particle.new 
      part.x = actor.x
      part.y = actor.y
      part.r = 100+rand(155)
      part.g = rand(155)
      part.b = rand(155)
      part.a = 100+rand(155)
      rot = rand(Math::PI*100*2)/100.0
      part.dir = Vector2.new(-1,0).rotate(rot)
      part.speed = rand(10)*0.5

      part.ttl = 1000
      actor.total_particles -= 1

      part
    end

    def update(time)
      actor.particles.each do |part|
        new_loc = part.dir * part.speed
        part.x += new_loc.x
        part.y += new_loc.y
        part.a *= 0.95
        part.speed *= 0.95
        part.ttl -= time
      end

      # kill off the dead ones
      actor.particles.delete_if do |part|
        part.ttl <= 0
      end

      if actor.total_particles <= 0
        # all out of particles
        actor.remove
      else
        new_parts = [actor.active_particle_limit - actor.particles.size, actor.max_particle_created_per_step].min
        new_parts.times do
          actor.particles << create_particle
        end
      end
    end
  end
end

define_actor :particle_system do
  has_behaviors :positioned, :particles, layered: 4
end
