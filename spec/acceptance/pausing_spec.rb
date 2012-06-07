require 'helper'

describe "pausing in gamebox", acceptance: true do

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

  define_actor :mountain do
    has_behavior :shoot_rock
  end


  it 'allows timers and all updates from the director to be paused / unpaused' do
    game.stage do |stage|
      @counter = 0
      timer_manager.add_timer 'stage_timer', 200 do
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

    update 10
    see_actor_attrs :mountain, rocks_shot: 0
    see_stage_ivars counter: 0

    update 91
    see_actor_attrs :mountain, rocks_shot: 1
    see_stage_ivars counter: 0

    press_key KbP
    game.should have_actor(:label)
    update 201
    see_actor_attrs :mountain, rocks_shot: 1
    see_stage_ivars counter: 0

    update 201
    see_actor_attrs :mountain, rocks_shot: 1
    see_stage_ivars counter: 0

    press_key KbP
    game.should_not have_actor(:label)
    update 201
    see_actor_attrs :mountain, rocks_shot: 2
    see_stage_ivars counter: 1
  end

  it 'modal actor pauses, shows actor, unpauses when that actor dies' do
    game.stage do |stage|
      modal_actor :label, text: "pause" do
        @some_unpause_indicator = true
      end
    end

    see_stage_ivars some_unpause_indicator: nil
    game.should have_actor(:label)
    see_actor_attrs :label, text: "pause"

    remove_actor :label

    game.should_not have_actor(:label)
    see_stage_ivars some_unpause_indicator: true
  end

end





