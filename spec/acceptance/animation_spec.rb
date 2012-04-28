require 'helper'

describe "Using timers" do
  before do
    Gamebox.configure do |config|
      config.config_path = "spec/fixtures/"
      config.music_path = "spec/fixtures/"
      config.sound_path = "spec/fixtures/"
      config.gfx_path = "spec/fixtures/"
      config.stages = [:testing]
    end

    Conject.instance_variable_set '@default_object_context', nil
    HookedGosuWindow.stubs(:new).returns(gosu)
  end
  let(:gosu) { MockGosuWindow.new }

  let!(:snelpling_idle_png) { mock_image('snelpling/idle/1.png') }
  let!(:snelpling_jump_1_png) { mock_image('snelpling/jump/1.png') }
  let!(:snelpling_jump_2_png) { mock_image('snelpling/jump/2.png') }
  let!(:snelpling_jump_3_png) { mock_image('snelpling/jump/3.png') }

  define_behavior :jump_on_j do
    requires :input_manager
    setup do
      input_manager.reg :down, KbJ do
        actor.action = :jump
      end
    end
  end
  define_actor_view :snelpling_view do
    draw do |target, x_off, y_off, z|
      actor.image.draw #offset_x, offset_y, z, x_scale, y_scale, color
    end
  end
  define_actor :snelpling do
    # TODO how to hook up "if no view defined use graphical_actor_view"?
    has_behavior :jump_on_j
    has_behavior :animated
  end

  it 'animates correctly' do
    game.stage do |stage| # instance of TestingStage
      create_actor :snelpling
    end

    see_actor_attrs :snelpling, 
      action: :idle,
      image: snelpling_idle_png

    draw
    see_image_drawn snelpling_idle_png

    update 60
    draw
    see_image_drawn snelpling_idle_png

    press_key KbJ
    draw

    see_image_drawn snelpling_jump_1_png
    update 60
    draw

    see_image_drawn snelpling_jump_2_png
    update 60
    draw

    see_image_drawn snelpling_jump_3_png
    update 60
    draw

    see_image_drawn snelpling_jump_1_png

    pending "add callback checks?"
  end

end

