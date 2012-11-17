require 'helper'

describe "Using input mapper", acceptance: true do

  define_actor :foxy do
  end

  it 'sets actor state based on input' do
    game.stage do |stage| # instance of TestingStage
      foxy = create_actor :foxy
      foxy.input.map_input 'left' => :move_left,
                           'right' => :move_right,
                           'd' => :move_right
    end

    input = game.actor(:foxy).input
    input.move_left?.should be_false
    input.move_right?.should be_false

    press_key KbLeft
    press_key KbD

    input.move_left?.should be_true
    input.move_right?.should be_true

    release_key KbD
    input.move_left?.should be_true
    input.move_right?.should be_false


    press_key KbRight
    input.move_left?.should be_true
    input.move_right?.should be_true

    release_key KbRight
    input.move_left?.should be_true
    input.move_right?.should be_false
  end

end

