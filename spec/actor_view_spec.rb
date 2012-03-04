require File.join(File.dirname(__FILE__),'helper')


describe ActorView do
  subject { create_actor_view(:actor_view, @actor) }

  before do
    @actor = stub 'actor', when: nil
  end

  it 'should be layered 0/1 by default' do
    @actor.expects(:is?).with(:layered).returns(false)
    subject.layer.should == 0
    subject.parallax.should == 1
  end

  it 'should call setup on creation' do
    ActorView.any_instance.expects :setup
    @actor.expects(:is?).with(:layered).returns(false)
    subject
  end

  it 'should accept layered behavior params from actor' do
    @actor.stubs(:layer => 6, :parallax => 3)
    @actor.expects(:is?).with(:layered).returns(true)

    subject.layer.should == 6
    subject.parallax.should == 3
  end

  context 'with a real Actor' do
    before do
      @actor = create_actor :actor
      subject.actor = @actor
    end
    
    it 'should register for show events' do
      @stage.expects(:register_drawable).with(subject)
      @actor.send :fire, :show_me
    end

    it 'should register for hide events' do
      @stage.expects(:unregister_drawable).with(subject)
      @actor.send :fire, :hide_me
    end

    it 'should register for remove events' do
      @stage.expects(:unregister_drawable).with(subject)
      @actor.send :fire, :remove_me
    end
  end
    
  it 'should manage a cached surface for drawing (possibly use record{})' 
end
