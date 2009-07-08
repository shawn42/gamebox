require 'actor'
require 'actor_view'
require 'ftor'
class ParticleSystemView < ActorView
  def draw(target, x_off, y_off)
    ax = @actor.x + x_off
    ay = @actor.y + y_off
    @actor.particles.each do |part|
      target.draw_circle_s [part.x,part.y], 3, [part.r,part.g,part.b,part.a]

    end
#    target.draw_circle [ax,ay], 20, [200,200,255,140]
  end
end

class Particle < Struct.new(:x,:y,:r,:g,:b,:a,:dir,:speed,:ttl)
end

# Class to generate particles
class ParticleSystem < Actor
  has_behaviors :updatable, :layered => 4

  attr_accessor :particles
  DEFAULT_SETTINGS = {
    :active_particle_limit => 90,
    :total_particles => 200
  }

  def setup
    @active_particle_limit = 350
    @max_particle_created_per_step = 90
    @total_particles = 400
    @particles = []
  end

  def create_particle
    part = Particle.new 
    part.x = self.x
    part.y = self.y
    part.r = 100+rand(155)
    part.g = rand(155)
    part.b = rand(155)
    part.a = 100+rand(155)
    rot = rand(Math::PI*100*2)/100.0
    part.dir = Ftor.new(-1,0).rotate(rot)
    part.speed = rand(10)*0.5

    part.ttl = 1000
    @total_particles -= 1

    part
  end

  def update(time)
    @particles.each do |part|
      new_loc = part.dir * part.speed
      part.x += new_loc.x
      part.y += new_loc.y
      part.a *= 0.95
      part.speed *= 0.95
      part.ttl -= time
    end

    # kill off the dead ones
    @particles.delete_if do |part|
      part.ttl <= 0
    end

    if @total_particles <= 0
      # all out of particles
      remove_self
    else
      new_parts = [@active_particle_limit - @particles.size, @max_particle_created_per_step].min
      new_parts.times do
        @particles << create_particle
      end
    end
    remove_self if @particles.empty?
  end

end
