require File.join(File.dirname(__FILE__),'helper')


describe 'A new actor view' do
  before do
    @actor = mock
    @stage = mock
    @actor.stubs :when
  end

  it 'should be layered 0/1 by default' do
    @actor.expects(:is?).with(:layered).returns(false)
    @test_me = ActorView.new @stage, @actor, :wrapped_screen
    @test_me.layer.should == 0
    @test_me.parallax.should == 1
  end

  it 'should call setup on creation' do
    ActorView.any_instance.expects :setup
    @actor.expects(:is?).with(:layered).returns(false)
    @test_me = ActorView.new @stage, @actor, :wrapped_screen
  end

  it 'should accept layered behavior params from actor' do
    @actor.stubs(:layer => 6, :parallax => 3)
    @actor.expects(:is?).with(:layered).returns(true)
    @test_me = ActorView.new @stage, @actor, :wrapped_screen

    @test_me.layer.should == 6
    @test_me.parallax.should == 3
  end
  
  it 'should register for show events' do
    @actor = Actor.new({})
    
    @test_me = ActorView.new @stage, @actor, :wrapped_screen
    @stage.expects(:register_drawable).with(@test_me)
    
    @actor.send :fire, :show_me
  end

  it 'should register for hide events' do
    @actor = Actor.new({})
    
    @test_me = ActorView.new @stage, @actor, :wrapped_screen
    @stage.expects(:unregister_drawable).with(@test_me)
    
    @actor.send :fire, :hide_me
  end

  it 'should register for remove events' do
    @actor = Actor.new({})
    
    @test_me = ActorView.new @stage, @actor, :wrapped_screen
    @stage.expects(:unregister_drawable).with(@test_me)
    
    @actor.send :fire, :remove_me
  end
  
  it 'should manage a cached surface for drawing (possibly use record{})' 
end
