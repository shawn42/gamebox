require 'helper'

describe "Using input mapper", acceptance: true do

  define_actor :foxy do
  end

  it 'sets actor state based on input' do
    game.stage do |stage| # instance of TestingStage
      foxy = create_actor :foxy
      foxy.controller.map_controls 'left'  => :move_left,
                                   'right' => :move_right,
                                   'd'     => :move_right
    end

    controller = game.actor(:foxy).controller
    controller.move_left?.should be_false
    controller.move_right?.should be_false

    press_key KbLeft
    press_key KbD

    controller.move_left?.should be_true
    controller.move_right?.should be_true

    release_key KbD
    controller.move_left?.should be_true
    controller.move_right?.should be_false


    press_key KbRight
    controller.move_left?.should be_true
    controller.move_right?.should be_true

    release_key KbRight
    controller.move_left?.should be_true
    controller.move_right?.should be_false
  end

end

