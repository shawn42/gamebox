# class used for particle emissions
class Emitter < Actor
  
  # options:
  # delay: ms to wait between creating more particles
  # particle_actor: actor to spawn as particle
  # particle_opts: opts to be passed to the spawned particle
  # ttl: ms to live (optional, will live forever if omitted)
  # spawn_variance: dist in pixels to spawn away from emitter (default -10..10)
  # location_tween: tween object that will be used to move the emitter (optional)
  # follow: actor to follow (optional)
  def setup
    @variance = opts[:spawn_variance] || (-10..10)

    spawn_timer = "#{self.object_id}_spawn"
    self.when :remove_me do
      stage.remove_timer spawn_timer
    end
    stage.add_timer spawn_timer, opts[:delay] do
      spawn_particle
    end
    ttl = opts[:ttl]
    if ttl
      suicide_timer = "#{self.object_id}_ttl" 
      self.when :remove_me do
        stage.remove_timer suicide_timer
      end
      stage.add_timer suicide_timer, ttl do
        remove_self
      end
    end

  end

  def spawn_particle
    spawn_x = self.x + @variance.sample
    spawn_y = self.y + @variance.sample

    spawn opts[:particle_actor], {x: spawn_x, y: spawn_y}.merge(opts[:particle_opts])
  end
end
