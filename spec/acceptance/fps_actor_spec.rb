require 'helper'

describe "Using fps actor", acceptance: true do

  let!(:arial_20) { mock_font('arial', 20) }

  it 'draws and updates the fps label' do
    game.stage do |stage|
      @fps = create_actor :fps, font_name: 'arial', font_size: 20, color: Color::RED
    end

    game.should have_actor(:fps)
    game.should have_actor(:label)
    draw
    see_text_drawn "", in: arial_20, color: Color::RED

    Gosu.stubs(:fps).returns(99)
    draw
    see_text_drawn "", in: arial_20, color: Color::RED

    update 100
    draw
    see_text_drawn "99", in: arial_20, color: Color::RED

    remove_fps

    game.should_not have_actor(:fps)
    game.should_not have_actor(:label)
  end

  def remove_fps
    game.current_stage.instance_variable_get("@fps").remove
  end

end

