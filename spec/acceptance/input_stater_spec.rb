require 'helper'

describe "Using input stater", acceptance: true do


  define_actor :foxy do
    has_behavior input_stater: {
      [KbLeft] => :move_left,
      [KbRight, KbD] => :move_right
    }
  end

  it 'sets actor state based on input' do
    game.stage do |stage| # instance of TestingStage
      create_actor :foxy
    end

    see_actor_attrs :foxy, 
      move_left: false
    see_actor_attrs :foxy, 
      move_right: false

    press_key KbLeft
    press_key KbD

    see_actor_attrs :foxy, 
      move_left: true

    see_actor_attrs :foxy, 
      move_right: true

    release_key KbD
    see_actor_attrs :foxy, 
      move_right: false

    press_key KbRight

    see_actor_attrs :foxy, 
      move_right: true

    release_key KbRight

    see_actor_attrs :foxy, 
      move_right: false
  end

end

