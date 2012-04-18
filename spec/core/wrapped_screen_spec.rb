require 'helper'

describe WrappedScreen do
  inject_mocks :config_manager

  describe "#setup" do
    before do
      @config_manager.stubs(:[]).with(:screen_resolution).returns [800,555]
      @config_manager.stubs(:[]).with(:fullscreen).returns false
      @config_manager.stubs(:[]).with(:title).returns "Some Title!"
      @config_manager.stubs(:[]).with(:needs_cursor).returns nil

      @gosu_window = stub('gosu window')
      HookedGosuWindow.stubs(:new).with(800, 555, false).returns @gosu_window
    end

    it 'creates a new Gosu Window with opts from config manager' do

      @gosu_window.expects(:caption=).with("Some Title!")
      @gosu_window.expects(:needs_cursor=).with(nil)

      subject.screen.should == @gosu_window
    end
  end
end

