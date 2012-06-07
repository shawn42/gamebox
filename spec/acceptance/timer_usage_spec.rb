require 'helper'

describe "Using timers", acceptance: true do

  define_behavior :shoot_rock do |beh|
    beh.requires :timer_manager
    beh.setup do
      actor.has_attributes rocks_shot: 0
      timer_manager.add_timer 'shoot_rock', 100 do
        actor.react_to :shoot_rock
      end
    end

    react_to do |msg, *args|
      actor.rocks_shot += 1 if msg == :shoot_rock
    end
  end

  define_actor :volcano do
    has_behavior :shoot_rock
  end


  it 'allows behaviors to get fired from timers' do
    game.stage do |stage| # instance of TestingStage
      @counter = 0
      timer_manager.add_timer 'stage_timer', 200 do
        @counter += 1
      end
      create_actor :volcano
    end
    see_actor_attrs :volcano, rocks_shot: 0
    see_stage_ivars counter: 0

    update 10
    see_actor_attrs :volcano, rocks_shot: 0
    see_stage_ivars counter: 0

    update 91
    see_actor_attrs :volcano, rocks_shot: 1
    see_stage_ivars counter: 0

    update 201
    see_actor_attrs :volcano, rocks_shot: 2
    see_stage_ivars counter: 1

    update 1
    see_actor_attrs :volcano, rocks_shot: 3
    see_stage_ivars counter: 1
  end

end

