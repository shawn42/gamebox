require File.join(File.dirname(__FILE__),'helper')

describe InputManager do
  inject_mocks :config_manager, :wrapped_screen
  before do
    @config_manager.stubs(:[] => nil)
    @window = evented_stub(stub('window', mouse_x: 43, mouse_y: 12))
    @wrapped_screen.stubs(screen: @window)
    subject.register game
  end
  let(:game) { stub('game') }

  describe "mouse drag event" do
    it "fires after a mouse down, mouse motion, mouse up" do
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

      fire_event(subject, MsLeft, :down)
      pretend_event(subject, nil, :motion)
      @window.stubs(:mouse_x).returns(to_x)
      @window.stubs(:mouse_y).returns(to_y)
      fire_event(subject, MsLeft, :up)

    end
  end

  describe "non-id specific events" do
    it 'calls callback for all keyboard events' do
      key_pressed = 0
      subject.reg :keyboard_down do
        key_pressed += 1
      end

      fire_event(subject, KbT, :up)
      key_pressed.should == 0

      # fire_event(subject, MsLeft, :down)
      # key_pressed.should == 0

      fire_event(subject, KbT, :down)
      key_pressed.should == 1
    end

    it 'calls callback for all mouse events' do
      mouse_pressed = 0
      subject.reg :mouse_down do
        mouse_pressed += 1
      end

      fire_event(subject, MsLeft, :up)
      mouse_pressed.should == 0

      # fire_event(subject, KbT, :down)
      # mouse_pressed.should == 0

      fire_event(subject, MsLeft, :down)
      mouse_pressed.should == 1
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

      fire_event(subject, KbT, :down)
      r_pressed.should == 0
      y_pressed.should == 0

      fire_event(subject, KbR, :up)
      r_pressed.should == 0
      y_pressed.should == 0

      fire_event(subject, KbR, :down)
      r_pressed.should == 1
      y_pressed.should == 0

      fire_event(subject, KbY, :down)
      r_pressed.should == 1
      y_pressed.should == 1

      subject.clear_hooks self

      # has now been unregistered
      fire_event(subject, KbR, :down)
      r_pressed.should == 1

      fire_event(subject, KbY, :down)
      y_pressed.should == 1
    end

    it 'passes along args'
  end

  describe "mapping an event id to a boolean" do
    it "sets an ivar to true as long as the event id is down" do
      listener = Struct.new(:left).new
      subject.while_pressed KbLeft, listener, :left

      listener.left.should be_false

      fire_event(subject, KbLeft, :down)
      listener.left.should be_true

      fire_event(subject, GpLeft, :down)
      listener.left.should be_true

      fire_event(subject, GpLeft, :up)
      listener.left.should be_true

      fire_event(subject, KbT, :up)
      listener.left.should be_true

      fire_event(subject, KbLeft, :up)
      listener.left.should be_false
    end
  end

  describe "mapping multiple keys to a boolean" do
    it "sets an ivar to true as long as ANY of the keys are down" do
      listener = Struct.new(:left).new
      subject.while_pressed [KbLeft, GpLeft], listener, :left

      listener.left.should be_false

      fire_event(subject, KbLeft, :down)
      listener.left.should be_true

      fire_event(subject, GpLeft, :down)
      listener.left.should be_true

      fire_event(subject, KbT, :up)
      listener.left.should be_true

      fire_event(subject, KbP, :down)
      listener.left.should be_true

      fire_event(subject, GpLeft, :up)
      listener.left.should be_true

      fire_event(subject, KbLeft, :up)
      listener.left.should be_false
    end
  end

  describe 'clearing events' do
    it 'clears an event by listener when registered by button id' do
      pressed = false
      subject.reg :keyboard_down, KbLeft do
        pressed = true
      end

      subject.clear_hooks self
      fire_event(subject, KbLeft, :down)
      pressed.should == false
    end

    it 'clears an event by listener when registered without button id' do
      pressed = false
      subject.reg :keyboard_down do
        pressed = true
      end

      subject.clear_hooks self
      fire_event(subject, KbLeft, :down)
      pressed.should == false
    end

    it 'clears all events if no listener is provided' do
      pressed = false
      subject.reg :keyboard_down do
        pressed = true
      end

      subject.clear_hooks
      fire_event(subject, KbLeft, :down)
      pressed.should == false
    end

  end

  describe "#show" do
    before do
      @window.stubs(:show)
      @wrapped_screen.stubs(screen: @window)
    end

    it 'shows the window' do
      @window.expects(:show)
      subject.show
    end
  end

  describe "#register" do
    it 'handles an update event' do
      game.expects(:update).with(:millis)
      @window.fire :update, :millis
    end

    it 'handles a draw event' do
      game.expects(:draw)
      @window.fire :draw
    end
  end

  describe 'registering actors' do
    it 'unregisters actors on death' do
      subject
      tom_cruise = create_actor :actor
      called = false
      subject.send :_register_hook, tom_cruise, :down, KbSpace do
        called = true
      end

      tom_cruise.send :fire, :remove_me, tom_cruise
      fire_event(subject, KbSpace, :down)
      called.should be_false
    end
  end

  it 'tracks the mouse motion events'
  it 'cleanly removes handlers not using ids'
  describe 'pausing' do
    it 'pause/unpause' do
      key_pressed = 0
      subject.reg :keyboard_down do
        key_pressed += 1
      end

      fire_event(subject, KbT, :down)
      key_pressed.should == 1

      subject.pause

      fire_event(subject, KbT, :down)
      key_pressed.should == 1

      paused_pressed = 0
      subject.reg :keyboard_down do
        paused_pressed += 1
      end

      fire_event(subject, KbT, :down)
      paused_pressed.should == 1

      subject.unpause
      fire_event(subject, KbT, :down)
      paused_pressed.should == 1
      key_pressed.should == 2
    end
  end

  private
  def fire_event(target, id, direction)
    @window.fire "button_#{direction}".to_sym, id
  end

  def pretend_event(target, id, direction)
    target.send :handle_event, id, direction
  end

end
