define_actor :alien do
  has_attributes action: :march, view: :graphical_actor_view

  has_behaviors do 
    animated          frame_update_time: 900
    collidable        shape: :polygon, cw_local_points: [[4,4],[44,4],[44,44],[4,44]]
    projectile        speed: 0.01, direction: vec2(1,0)
    reversable_direction
    increasing_speed  accel: 0.001
    drops             fall_amount: 25
    shooter           shoots: :alien_missile, direction: vec2(0,-1)
  end

end
