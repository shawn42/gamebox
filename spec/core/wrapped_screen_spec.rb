require 'helper'

describe WrappedScreen do
  inject_mocks :config_manager

  before do
    @config_manager.stubs(:[]).with(:screen_resolution).returns [800,555]
    @config_manager.stubs(:[]).with(:fullscreen).returns false

    @gosu_window = stub('gosu window', :caption= => nil, :needs_cursor= => nil)
    HookedGosuWindow.stubs(:new).with(800, 555, false).returns @gosu_window
  end

  describe "#setup" do
    it 'creates a new Gosu Window with opts from config manager' do

      @gosu_window.expects(:caption=).with(Gamebox.configuration.game_name)
      @gosu_window.expects(:needs_cursor=).with(Gamebox.configuration.needs_cursor?)

      subject.screen.should == @gosu_window
    end
  end

  describe "#draw_rotated_image" do
    it 'passes the args along to the image to draw itself' do
      image = mock
      image.expects(:draw_rot).with(:x, :y, :z, :angle, :cx, :cy, :sx, :sy, :color, :mode)
      subject.draw_rotated_image(image, :x, :y, :z, :angle, :cx, :cy, :sx, :sy, :color, :mode)
    end
  end
end

