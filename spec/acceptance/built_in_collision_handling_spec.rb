require 'helper'

describe "Using gamebox's built in collision handling", acceptance: true do

  define_actor :frickin_laser do
    has_behavior :projectile
    has_behavior collidable: {shape: :polygon, points: [[0,0],[10,7],[20,10]]}
  end

  define_actor :alien do
    has_behavior collidable: {shape: :circle, radius: 10}
  end

  it 'shows that two overlapping objects collide' do
    #scope cheatzys
    laser = nil
    alien = nil
    game.stage do |stage| # instance of TestingStage
      laser = create_actor :frickin_laser, x: 0, y: 0, vel_x: 5, vel_y: 1
      alien = create_actor :alien, x: 0, y: 0
      on_collision_of :frickin_laser, :alien do |collision_laser, collision_alien|
        @collision_laser = collision_laser
        @collision_alien = collision_alien
      end
    end
    see_stage_ivars collision_laser: nil, collision_alien: nil
    update 1
    # TODO not sure about this one..
    update 1
    see_stage_ivars collision_laser: laser, collision_alien: alien
  end

  it 'shows that an object in motion can collide' do
    laser = nil
    alien = nil
    game.stage do |stage| # instance of TestingStage
      laser = create_actor :frickin_laser, x: 0, y: 0, vel_x: 5, vel_y: 0
      alien = create_actor :alien, x: 31, y: 0
      on_collision_of :frickin_laser, :alien do |collision_laser, collision_alien|
        @collision_laser = collision_laser
        @collision_alien = collision_alien
      end
    end
    see_stage_ivars collision_laser: nil, collision_alien: nil
    # now the laser moved and will be checked for collisions _next_ update
    update 1
    # trigger the next round of collision detection
    update 2000
    # TODO not sure about this one..
    update 1
    see_stage_ivars collision_laser: laser, collision_alien: alien
  end

end

