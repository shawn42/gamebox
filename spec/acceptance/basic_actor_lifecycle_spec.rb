require 'helper'

describe "The basic life cycle of an actor", acceptance: true do
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
    setup do
      input_manager.reg :up, KbD do
        actor.remove
      end
    end
  end

  define_behavior :positioned_on_p do
    requires :input_manager
    setup do
      input_manager.reg :up, KbP do
        add_behavior :positioned, x: 500, y:30
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
      target.draw_image @image, 1, 2, 3
    end
  end

  # no code is allowed in the actor!
  # all done through behaviors
  define_actor :mc_bane do
    has_behaviors do
      shooty bullets: 50
      death_on_d
      positioned_on_p
    end
  end

  define_actor :monkey do
    has_attributes bananas: 3
  end


  it 'creates an actor from within stage with the correct behaviors and updates' do
    game.stage do |stage|
      create_actor :mc_bane, x: 250, y: 400
    end
    see_actor_attrs :mc_bane, bullets: 50

    update 10
    see_image_not_drawn mc_bane_png

    draw
    see_image_drawn mc_bane_png

    see_actor_attrs :mc_bane, bullets: 40
    game.should have_actor(:mc_bane)

    release_key KbD

    # should have removed himself
    game.should_not have_actor(:mc_bane)

  end

  it 'can dynamically add behaviors' do
    game.stage do |stage|
      create_actor :mc_bane
    end
    see_no_actor_attrs :mc_bane, :x, :y
    
    release_key KbP
    see_actor_attrs :mc_bane, x: 500, y: 30
  end

  it 'uses default values from actor definition' do
    game.stage do |stage|
      create_actor :monkey
    end
    see_actor_attrs :monkey, bananas: 3
  end

end

