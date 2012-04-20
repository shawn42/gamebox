require 'helper'

describe "The basic life cycle of an actor" do
  before do
    Gamebox.configure do |config|
      config.config_path = "spec/fixtures/"
      config.music_path = "spec/fixtures/"
      config.sound_path = "spec/fixtures/"
    end

    Conject.instance_variable_set '@default_object_context', nil
    HookedGosuWindow.stubs(:new).returns(gosu)
  end
  let(:gosu) { MockGosuWindow.new }
  let!(:mc_bane_png) { mock_image('mc_bane.png') }

  define_behavior :shooty do |beh|
    beh.requires :director
    beh.setup do
      actor.has_attribute :bullets, opts[:bullets]
      director.when :update do |time|
        actor.bullets -= time
      end
    end
  end

  define_behavior :death_on_d do
    requires :input_manager
    # TODO can we rename this to configure?
    setup do
      input_manager.reg :up, KbD do
        actor.remove
      end
    end
  end

  define_actor_view :mc_bane_view do
    requires :resource_manager # needs these injected
    configure do
      @image = resource_manager.load_actor_image(actor)
    end

    draw do |target, x_off, y_off, z|
      # TODO TRACK THESE DRAWINGS
      @image.draw #offset_x, offset_y, z, x_scale, y_scale, color
    end
  end

  # no code is allowed in the actor!
  # all done through behaviors
  define_actor :mc_bane do
    has_behavior  shooty: { bullets: 50 }
    has_behavior :death_on_d
    # actor.has_behavior :graphical

    # FEATURE REQUEST
    # actor.has_view do |view|
    #   view.uses :resource_manager
    #   view.configure do
    #   end

    #   view.draw do |target, x_off, y_off, z|
    #   end
    # end
  end


  it 'creates an actor from within stage with the correct behaviors and updates' do
    # going for a capybara style "page" reference for the game
    game.stage do |stage| # instance of TestingStage
      create_actor :mc_bane, x: 250, y: 400
    end
    see_actor_attrs :mc_bane, bullets: 50

    update 10
    see_image_drawn mc_bane_png

    see_actor_attrs :mc_bane, bullets: 40
    game.should have_actor(:mc_bane)

    send_up KbD

    # should have removed himself
    game.should_not have_actor(:mc_bane)

    # TODO interaction of actors could get tested this way as well
    # TODO rendering checks?
  end
end

