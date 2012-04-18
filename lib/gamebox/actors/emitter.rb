# actor used for particle emissions
Actor.define :emitter do
  # options:
  # delay: ms to wait between creating more particles
  # particle_actor: actor to spawn as particle
  # particle_opts: opts to be passed to the spawned particle
  # ttl: ms to live (optional, will live forever if omitted)
  # spawn_variance: dist in pixels to spawn away from emitter (default -10..10)
  # location_tween: tween object that will be used to move the emitter (optional)
  # follow: actor to follow (optional)
  has_behavior :emitting
end
