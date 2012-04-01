require File.join(File.dirname(__FILE__),'helper')

describe 'A new animated behavior' do
  subject { create_conjected_object :animated, actor }
  let(:actor) { create_actor }

  before do
    @rm = stub(:load_animation_set => ['1.png_img_obj','2.png_img_obj'])
    @actor = create_actor
    @actor.expects(:is?).with(:updatable).returns(true)
    @actor.stubs(:resource_manager).returns(@rm)
  end

  it 'should define methods on actor' do
    @actor.respond_to?(:image).should be(true)
    @actor.respond_to?(:start_animating).should be(true)
    @actor.respond_to?(:stop_animating).should be(true)
    @actor.respond_to?(:action=).should be(true)
    @actor.respond_to?(:animated).should be(true)
  end

  it 'shouldn\'t update frame for non-animating' do
    subject.stop_animating

    subject.update subject.frame_update_time+1

    subject.frame_time.should equal(0)
    subject.frame_num.should equal(0)
  end

  it 'should update frame for animating' do
    time_passed = subject.frame_update_time-1
    subject.update time_passed
    subject.frame_time.should equal(time_passed)
    subject.frame_num.should equal(0)

    time_passed_again = 2
    subject.update time_passed_again
    # we rolled over the time
    subject.frame_time.should equal(1)
    subject.frame_num.should equal(1)

    time_passed_again = subject.frame_update_time
    subject.update time_passed_again
    # we rolled over the time
    subject.frame_time.should equal(1)
    subject.frame_num.should equal(0)
  end

  it 'should stop animating' do
    subject.stop_animating
    subject.animating.should equal(false)
  end

  it 'should start animating' do
    subject.start_animating
    subject.animating.should equal(true)
  end
  
  it 'should return itself for animated' do
    subject.animated.should == subject
  end

  it 'should set the action and animate accordingly for single frame' do
    subject.animating = true
    @rm.expects(:load_animation_set).with(@actor, :foo).returns([:frame_one])
    subject.action = :foo
    
    subject.animating.should be_false
    subject.frame_num.should == 0
    subject.action.should == :foo
  end

  it 'should set the action and animate accordingly for many frames' do
    subject.animating = false
    @rm.expects(:load_animation_set).with(@actor, :foo).returns([:frame_one, :frame_two])
    subject.action = :foo
    
    subject.animating.should be_true
    subject.frame_num.should == 0
    subject.action.should == :foo
  end


end
