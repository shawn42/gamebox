require 'helper'

describe "Using chipmunks collision handling", acceptance: true do

  define_actor :rock do
    has_behavior :physical => {:shape => :circle, 
      :mass => 10,
      :friction => 1.7,
      :elasticity => 0.4,
      :radius => 10,
      :moment => 150 
    }
  end

  define_actor :hard_place do
    has_behavior :physical => {:shape => :circle, 
      :mass => 10,
      :friction => 1.7,
      :elasticity => 0.4,
      :radius => 10,
      :moment => 150 
    }
  end

  it 'shows that two overlapping objects collide' do
    #scope cheatzys
    rock = nil
    hard_place = nil
    game.stage do |stage| # instance of TestingStage
      # TODO order issue here
      require 'chipmunk'
      load "#{GAMEBOX_PATH}core/physics.rb"
      @physics_manager = this_object_context[:physics_manager]
      @physics_manager.configure
      # TODO move these optionally to configure?
      @physics_manager.elastic_iterations = 4
      @physics_manager.damping = 0.4

      rock = create_actor :rock, x: 0, y: 0
      hard_place = create_actor :hard_place, x: 0, y: 0
      @physics_manager.add_collision_func :rock, :hard_place do |collision_rock, collision_hard_place|
        @collision_rock = collision_rock
        @collision_hard_place = collision_hard_place
      end
    end
    see_stage_ivars collision_rock: nil, collision_hard_place: nil
    update 1
    # TODO not sure about this one..
    update 1
    see_stage_ivars collision_rock: rock, collision_hard_place: hard_place
  end

  # it 'shows that an object in motion can collide' do
  #   laser = nil
  #   alien = nil
  #   game.stage do |stage| # instance of TestingStage
  #     laser = create_actor :frickin_laser, x: 0, y: 0, vel_x: 5, vel_y: 0
  #     alien = create_actor :alien, x: 31, y: 0
  #     on_collision_of :frickin_laser, :alien do |collision_laser, collision_alien|
  #       @collision_laser = collision_laser
  #       @collision_alien = collision_alien
  #     end
  #   end
  #   see_stage_ivars collision_laser: nil, collision_alien: nil
  #   # now the laser moved and will be checked for collisions _next_ update
  #   update 1
  #   # trigger the next round of collision detection
  #   update 2000
  #   # TODO not sure about this one..
  #   update 1
  #   see_stage_ivars collision_laser: laser, collision_alien: alien
  # end

end

