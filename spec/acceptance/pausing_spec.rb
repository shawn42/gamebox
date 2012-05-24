require 'helper'

describe "pausing in gamebox", acceptance: true do

  define_behavior :shoot_rock do |beh|
    beh.requires :timer_manager
    beh.setup do
      actor.has_attributes rocks_shot: 0
      timer_manager.add_timer 'shoot_rock', 1_000 do
        actor.react_to :shoot_rock
      end
    end

    react_to do |msg, *args|
      actor.rocks_shot += 1 if msg == :shoot_rock
    end
  end

  define_actor :mountain do
    has_behavior :shoot_rock
  end


  it 'allows timers and all updates from the director to be paused / unpaused' do
    game.stage do |stage| # instance of TestingStage
      @counter = 0
      timer_manager.add_timer 'stage_timer', 2000 do
        @counter += 1
      end
      create_actor :mountain

      input_manager.reg :down, KbP do
        pause
      end

      on_pause do
        @pause_label = create_actor :label, text: "pause"
        input_manager.reg :down, KbP do
          unpause
        end
      end

      on_unpause do
        @pause_label.remove
      end
    end
    game.should_not have_actor(:label)
    see_actor_attrs :mountain, rocks_shot: 0
    see_stage_ivars counter: 0

    update 100
    see_actor_attrs :mountain, rocks_shot: 0
    see_stage_ivars counter: 0

    update 901
    see_actor_attrs :mountain, rocks_shot: 1
    see_stage_ivars counter: 0

    press_key KbP
    game.should have_actor(:label)
    update 2001
    see_actor_attrs :mountain, rocks_shot: 1
    see_stage_ivars counter: 0

    update 2001
    see_actor_attrs :mountain, rocks_shot: 1
    see_stage_ivars counter: 0

    press_key KbP
    game.should_not have_actor(:label)
    update 2001
    see_actor_attrs :mountain, rocks_shot: 2
    see_stage_ivars counter: 1
  end

end

