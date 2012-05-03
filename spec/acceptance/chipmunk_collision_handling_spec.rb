require 'helper'

describe "Using chipmunks collision handling", acceptance: true do

  define_actor :rock do
    has_behavior :physical => {shape: :circle, 
      mass: 10,
      friction: 1.7,
      elasticity: 0.4,
      radius: 10,
      moment: 150 
    }
  end

  define_actor :hard_place do
    has_behavior :physical => {shape: :circle, 
      mass: 10,
      friction: 1.7,
      elasticity: 0.4,
      radius: 10,
      moment: 150,
      fixed: true
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

  it 'shows that an object in motion can collide and that gravity is moving things' do
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
      @physics_manager.gravity = vec2(0,500)

      rock = create_actor :rock, x: 0, y: -20

      hard_place = create_actor :hard_place, x: 0, y: 0
      @physics_manager.add_collision_func :rock, :hard_place do |collision_rock, collision_hard_place|
        @collision_rock = collision_rock
        @collision_hard_place = collision_hard_place
      end
    end
    see_stage_ivars collision_rock: nil, collision_hard_place: nil
    update 500
    see_stage_ivars collision_rock: rock, collision_hard_place: hard_place
  end
end

