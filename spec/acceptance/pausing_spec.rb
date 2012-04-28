require 'helper'

describe "pausing in gamebox" do
  before do
    Gamebox.configure do |config|
      config.config_path = "spec/fixtures/"
      config.music_path = "spec/fixtures/"
      config.sound_path = "spec/fixtures/"
      config.stages = [:testing]
    end

    Conject.instance_variable_set '@default_object_context', nil
    HookedGosuWindow.stubs(:new).returns(gosu)
  end
  let(:gosu) { MockGosuWindow.new }

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

  define_actor :volcano do
    has_behavior :shoot_rock
  end


  it 'allows timers and all updates from the director to be paused / unpaused' do
    game.stage do |stage| # instance of TestingStage
      @counter = 0
      timer_manager.add_timer 'stage_timer', 2000 do
        @counter += 1
      end
      create_actor :volcano
    end
    see_actor_attrs :volcano, rocks_shot: 0
    see_stage_ivars counter: 0

    update 100
    see_actor_attrs :volcano, rocks_shot: 0
    see_stage_ivars counter: 0

    update 901
    see_actor_attrs :volcano, rocks_shot: 1
    see_stage_ivars counter: 0

    pause
    update 2001
    see_actor_attrs :volcano, rocks_shot: 1
    see_stage_ivars counter: 0

    update 2001
    see_actor_attrs :volcano, rocks_shot: 1
    see_stage_ivars counter: 0

    unpause
    update 2001
    see_actor_attrs :volcano, rocks_shot: 2
    see_stage_ivars counter: 1
    
    pending "add more actors _during_ the pause"
  end

end

