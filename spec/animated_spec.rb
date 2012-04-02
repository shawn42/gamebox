require File.join(File.dirname(__FILE__),'helper')

describe Animated do
  subject { 
    mocks = create_mocks *Animated.object_definition.component_names
    mocks[:actor] = actor
    Animated.new(mocks).configure
  }
  let(:actor) { create_actor }

  before do
    @director.stubs(:when)
    @rm = stub(:load_animation_set => ['1.png_img_obj','2.png_img_obj'])
    actor.stubs(:resource_manager).returns(@rm)
  end

  it 'should define attributes on actor' do
    subject
    actor.has_attribute?(:image).should be_true
    actor.has_attribute?(:action).should be_true
    actor.has_attribute?(:width).should be_true
    actor.has_attribute?(:height).should be_true
    actor.has_attribute?(:image=).should be_true
    actor.has_attribute?(:action=).should be_true
    actor.has_attribute?(:height=).should be_true
  end

  it 'shouldnt update frame for non-animating' do
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
    @rm.expects(:load_animation_set).with(actor, :foo).returns([:frame_one])
    subject.action = :foo

    subject.animating.should be_false
    subject.frame_num.should == 0
    subject.action.should == :foo
  end

  it 'should set the action and animate accordingly for many frames' do
    subject.animating = false
    @rm.expects(:load_animation_set).with(actor, :foo).returns([:frame_one, :frame_two])
    subject.action = :foo

    subject.animating.should be_true
    subject.frame_num.should == 0
    subject.action.should == :foo
  end

end
