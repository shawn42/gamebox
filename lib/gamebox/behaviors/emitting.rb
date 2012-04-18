Behavior.define :emitting do
  # options:
  # delay: ms to wait between creating more particles
  # particle_actor: actor to spawn as particle
  # particle_opts: opts to be passed to the spawned particle
  # ttl: ms to live (optional, will live forever if omitted)
  # spawn_variance: dist in pixels to spawn away from emitter (default -10..10)
  # location_tween: tween object that will be used to move the emitter (optional)
  # follow: actor to follow (optional)
  requires :stage
  setup do
    # TODO which opts do we want from actor and which from behavior?
    opts = actor.opts
    variance = opts[:spawn_variance] || (-10..10)

    spawn_timer = "#{self.object_id}_spawn"
    self.when :remove_me do
      stage.remove_timer spawn_timer
    end
    stage.add_timer spawn_timer, opts[:delay] do
      spawn_x = self.x + variance.sample
      spawn_y = self.y + variance.sample

      stage.spawn opts[:particle_actor], {x: spawn_x, y: spawn_y}.merge(opts[:particle_opts])
    end
    ttl = opts[:ttl]
    if ttl
      suicide_timer = "#{self.object_id}_ttl" 
      stage.add_timer suicide_timer, ttl do
        stage.remove_timer suicide_timer
        actor.remove
      end
    end

    target = opts[:follow]
    if target
      self.x = target.x
      self.y = target.y
      target.when :x_changed do
        self.x = target.x
      end
      target.when :y_changed do
        self.y = target.y
      end
    end

  end
end
