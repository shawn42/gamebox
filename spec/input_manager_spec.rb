require File.join(File.dirname(__FILE__),'helper')

describe InputManager do
  before do
    @config = stub(:[] => nil)
    @window = mock
    @wrapped_screen = stub(:screen => @window)
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

  describe "standard keyboard events" do
    it 'calls the callbacks for the correct events' do
      r_pressed = 0
      y_pressed = 0
      subject.reg :keyboard_down, KbR do
        r_pressed += 1
      end
      subject.reg :keyboard_down, KbY do
        y_pressed += 1
      end

      subject._handle_event(KbT, :down)
      r_pressed.should == 0
      y_pressed.should == 0

      subject._handle_event(KbR, :up)
      r_pressed.should == 0
      y_pressed.should == 0

      subject._handle_event(KbR, :down)
      r_pressed.should == 1
      y_pressed.should == 0

      subject._handle_event(KbY, :down)
      r_pressed.should == 1
      y_pressed.should == 1

      subject.clear_hooks self

      # has now been unregistered
      subject._handle_event(KbR, :down)
      r_pressed.should == 1

      subject._handle_event(KbY, :down)
      y_pressed.should == 1
    end

    it 'passes along args'
  end

  describe "mapping an event id to a boolean" do
    it "should set an ivar to true as long as the event id is down" do
      listener = Struct.new(:left).new
      subject.while_pressed KbLeft, listener, :left

      listener.left.should be_false

      subject._handle_event(KbLeft, :down)
      listener.left.should be_true

      subject._handle_event(GpLeft, :down)
      listener.left.should be_true

      subject._handle_event(GpLeft, :up)
      listener.left.should be_true

      subject._handle_event(KbT, :up)
      listener.left.should be_true

      subject._handle_event(KbLeft, :up)
      listener.left.should be_false
    end
  end

  describe "mapping multiple keys to a boolean" do
    it "should set an ivar to true as long as ANY of the keys are down" do
      pending
      listener = Struct.new(:left).new
      subject.while_pressed [KbLeft, GpLeft], listener, :left

      listener.left.should be_false

      subject._handle_event(KbLeft, :down)
      listener.left.should be_true

      subject._handle_event(GpLeft, :down)
      listener.left.should be_true

      subject._handle_event(KbT, :up)
      listener.left.should be_true

      subject._handle_event(KbP, :down)
      listener.left.should be_true

      subject._handle_event(GpLeft, :up)
      listener.left.should be_true

      subject._handle_event(KbLeft, :up)
      listener.left.should be_false
    end
  end

end
