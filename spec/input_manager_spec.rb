require File.join(File.dirname(__FILE__),'helper')

describe InputManager do
  before do
    @config = mock(:[] => nil)
    @window = mock
    @wrapped_screen = mock(:screen => @window)
  end
  let(:subject) { InputManager.new :config_manager => @config, :wrapped_screen => @wrapped_screen }

  describe "mouse drag event" do
    it "should fire after a mouse down, mouse motion, mouse up" do
      from_x = 40
      from_y = 20
      to_x = 140
      to_y = 120
      @window.stubs(:mouse_x).returns(from_x)
      @window.stubs(:mouse_y).returns(from_y)

      event_data = {:from => [from_x, from_y],:to => [to_x, to_y]}
      exp_event = {
        :type => :mouse, 
        :id => MsLeft,
        :action => :up,
        :callback_key => :mouse_drag,
        :data => event_data
      }

      subject.stubs(:fire).with(:event_received, any_parameters)

      subject.expects(:fire).with(:event_received, exp_event)

      subject._handle_event(MsLeft, :down)
      subject._handle_event(nil, :motion)
      @window.stubs(:mouse_x).returns(to_x)
      @window.stubs(:mouse_y).returns(to_y)
      subject._handle_event(MsLeft, :up)

    end
  end
end
